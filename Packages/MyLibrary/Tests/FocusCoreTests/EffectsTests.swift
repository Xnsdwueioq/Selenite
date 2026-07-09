// EffectsTests.swift
// FocusCoreTests
//
// Пинят КАНОНИЧЕСКИЙ ПОРЯДОК веера эффектов (не только состав).
// Остальные тесты используют `.contains`, поэтому порядок здесь — их дополнение.

import Foundation
import Testing
@testable import FocusCore

@Suite struct EffectsTests {

  static let now = Date(timeIntervalSince1970: 1_720_000_000)
  static let config = TimerConfig(
    sessionCount: 4,
    sessionDuration: 25,
    shortBreaksEnabled: true,
    shortBreakDuration: 30,
    longBreaksEnabled: true,
    longBreakDuration: 60
  )

  /// Идущая работа — `.reschedule` даст непустой план.
  func running() -> TimerState {
    var s = TimerState(config: Self.config)
    s.phase = .work(index: 0)
    s.currentIntervalStart = Self.now
    return s
  }

  /// Ожидание — `.reschedule` даст пустой план (границ впереди нет).
  func awaiting() -> TimerState {
    var s = TimerState(config: Self.config)
    s.phase = .awaiting(next: .shortBreak(afterIndex: 0))
    return s
  }

  private func savedSession(_ fx: [TimerEffect]) -> CompletedSession? {
    for e in fx { if case .saveCompleted(let s) = e { return s } }
    return nil
  }

  // MARK: - Порядок веера без сохранения сессии

  @Test func keepEmitsOnlySurfaceQuartetInOrder() {
    let s = running()
    let fx = TimerCore.effects(after: s, notifications: .keep)
    #expect(fx == [
      .persistSnapshot(s),
      .syncLiveActivity(s),
      .pushToWatch(s),
      .reloadWidgets,
    ])
  }

  @Test func cancelSitsBetweenSnapshotAndPushReaders() {
    let s = running()
    let fx = TimerCore.effects(after: s, notifications: .cancel)
    #expect(fx == [
      .persistSnapshot(s),
      .cancelNotifications,
      .syncLiveActivity(s),
      .pushToWatch(s),
      .reloadWidgets,
    ])
  }

  @Test func rescheduleWithFuturePlanEmitsReschedule() {
    let s = running()
    let plan = Schedule.boundaries(for: s, now: Self.now)
    #expect(!plan.isEmpty)   // санити: границы впереди есть

    let fx = TimerCore.effects(after: s, notifications: .reschedule(now: Self.now))
    #expect(fx == [
      .persistSnapshot(s),
      .rescheduleNotifications(plan),
      .syncLiveActivity(s),
      .pushToWatch(s),
      .reloadWidgets,
    ])
  }

  // Ключевое решение: пустой план вырождается в cancel, а не reschedule([]).
  @Test func rescheduleWithEmptyPlanDegradesToCancel() {
    let s = awaiting()
    #expect(Schedule.boundaries(for: s, now: Self.now).isEmpty)   // санити

    let fx = TimerCore.effects(after: s, notifications: .reschedule(now: Self.now))
    #expect(fx == [
      .persistSnapshot(s),
      .cancelNotifications,
      .syncLiveActivity(s),
      .pushToWatch(s),
      .reloadWidgets,
    ])
    #expect(!fx.contains(.rescheduleNotifications([])))
  }

  // MARK: - Сохранение сессии: календарь ВСЕГДА рядом (гейта в ядре нет)

  @Test func savingInsertsSaveThenCalendarRightAfterSnapshot() {
    let s = running()
    let session = CompletedSession.create(
      from: s, with: UUID(), terminationReason: .completed, sessionIndex: 0
    )
    let fx = TimerCore.effects(after: s, notifications: .cancel, saving: [session])
    #expect(fx == [
      .persistSnapshot(s),
      .saveCompleted(session),
      .addCalendarEvent(session),   // без всякого calendarSyncEnabled — политика в оболочке
      .cancelNotifications,
      .syncLiveActivity(s),
      .pushToWatch(s),
      .reloadWidgets,
    ])
  }

  // Несколько сессий (случай reconcile): каждая даёт пару save+calendar,
  // в порядке передачи, между snapshot и уведомлениями.
  @Test func multipleSessionsEmitSavePairsInOrder() {
    let s = running()
    let s0 = CompletedSession.create(from: s, with: UUID(), terminationReason: .completed, sessionIndex: 0)
    let s1 = CompletedSession.create(from: s, with: UUID(), terminationReason: .completed, sessionIndex: 1)
    let fx = TimerCore.effects(after: s, notifications: .keep, saving: [s0, s1])
    #expect(fx == [
      .persistSnapshot(s),
      .saveCompleted(s0), .addCalendarEvent(s0),
      .saveCompleted(s1), .addCalendarEvent(s1),
      .syncLiveActivity(s),
      .pushToWatch(s),
      .reloadWidgets,
    ])
  }

  // reloadWidgets — последним при любом наборе (после persist И saveCompleted).
  @Test func reloadWidgetsIsAlwaysLast() {
    let s = running()
    let session = CompletedSession.create(
      from: s, with: UUID(), terminationReason: .completed, sessionIndex: 0
    )
    let directives: [TimerCore.Notifications] = [.keep, .cancel, .reschedule(now: Self.now)]
    for notif in directives {
      #expect(TimerCore.effects(after: s, notifications: notif).last == .reloadWidgets)
      #expect(TimerCore.effects(after: s, notifications: notif, saving: [session]).last == .reloadWidgets)
    }
  }

  // MARK: - Интеграция через reduce

  // Граница работы в РУЧНОМ режиме: сессия сохраняется, календарь эмитится всегда,
  // а reschedule вырождается в cancel (впереди — awaiting без границ).
  @Test func workBoundaryManualProducesFullOrderedFan() {
    var s = TimerState(config: Self.config)
    s.phase = .work(index: 0)
    s.currentIntervalStart = Self.now
    let ctx = TimerContext(now: Self.now.addingTimeInterval(25), makeID: { UUID() })

    let (next, fx) = TimerCore.reduce(s, .boundaryReached, context: ctx)

    #expect(next.phase == .awaiting(next: .shortBreak(afterIndex: 0)))
    guard let saved = savedSession(fx) else {
      Issue.record("ожидали .saveCompleted в веере")
      return
    }
    #expect(fx == [
      .persistSnapshot(next),
      .saveCompleted(saved),
      .addCalendarEvent(saved),
      .cancelNotifications,
      .syncLiveActivity(next),
      .pushToWatch(next),
      .reloadWidgets,
    ])
  }

  // Граница работы в АВТО-режиме: следующая фаза бежит → reschedule с планом.
  @Test func workBoundaryAutoProducesRescheduleFan() {
    var cfg = Self.config
    cfg.autoAdvance = true
    var s = TimerState(config: cfg)
    s.phase = .work(index: 0)
    s.currentIntervalStart = Self.now
    let boundary = Self.now.addingTimeInterval(25)
    let ctx = TimerContext(now: boundary, makeID: { UUID() })

    let (next, fx) = TimerCore.reduce(s, .boundaryReached, context: ctx)

    #expect(next.phase == .shortBreak(afterIndex: 0))
    let plan = Schedule.boundaries(for: next, now: boundary)
    #expect(!plan.isEmpty)
    #expect(fx.contains(.rescheduleNotifications(plan)))
    #expect(!fx.contains(.cancelNotifications))
    #expect(fx.last == .reloadWidgets)
  }
}
