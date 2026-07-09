// ReconcileTests.swift
// FocusCoreTests
//
// Фокус: reconciled — догон пропущенных границ после сна/убийства процесса.
// Компактный конфиг (в секундах): work 10, shortBreak 5, longBreak 20, 2 сессии.

import Foundation
import Testing
@testable import FocusCore

@Suite struct ReconcileTests {

  static let now = Date(timeIntervalSince1970: 1_720_000_000)

  static func config(auto: Bool) -> TimerConfig {
    var cfg = TimerConfig(
      sessionCount: 2,
      sessionDuration: 10,
      shortBreaksEnabled: true,
      shortBreakDuration: 5,
      longBreaksEnabled: true,
      longBreakDuration: 20
    )
    cfg.autoAdvance = auto
    return cfg
  }

  func ctx(_ now: Date) -> TimerContext {
    TimerContext(now: now, makeID: { UUID() })
  }

  /// Работа №0 идёт с `now`.
  func runningWork0(auto: Bool) -> TimerState {
    var s = TimerState(config: Self.config(auto: auto))
    s.phase = .work(index: 0)
    s.currentIntervalStart = Self.now
    s.cycleID = UUID()
    return s
  }

  private func savedSessions(_ fx: [TimerEffect]) -> [CompletedSession] {
    fx.compactMap { effect in
      if case .saveCompleted(let session) = effect { return session }
      return nil
    }
  }

  // Авто: прокручивает несколько границ; даты сессий — ЧЕСТНЫЕ (границ, не now);
  // финальная фаза заякорена в последней границе, а не в now.
  @Test func autoRollsMultipleBoundariesWithHonestDates() {
    let s = runningWork0(auto: true)
    // Таймлайн: w0 [0..10] · sb [10..15] · w1 [15..25] · lb [25..45]
    // now = +30 → успели пройти w0, sb, w1; стоим на lb.
    let (final, fx) = TimerCore.reconciled(s, context: ctx(Self.now.addingTimeInterval(30)))

    #expect(final.phase == .longBreak)
    #expect(final.currentIntervalStart == Self.now.addingTimeInterval(25))   // якорь = последняя граница, НЕ +30

    let saved = savedSessions(fx)
    #expect(saved.count == 2)                                       // перерывы в историю не идут
    #expect(saved[0].sessionIndex == 0)
    #expect(saved[0].endDate == Self.now.addingTimeInterval(10))    // честная дата границы, не +30
    #expect(saved[1].sessionIndex == 1)
    #expect(saved[1].endDate == Self.now.addingTimeInterval(25))
  }

  // Ручной: прокручивает РОВНО одну границу и встаёт в awaiting (сам, без спец-условия).
  @Test func manualRollsExactlyOneBoundaryToAwaiting() {
    let s = runningWork0(auto: false)
    let (final, fx) = TimerCore.reconciled(s, context: ctx(Self.now.addingTimeInterval(30)))

    #expect(final.phase == .awaiting(next: .shortBreak(afterIndex: 0)))
    let saved = savedSessions(fx)
    #expect(saved.count == 1)
    #expect(saved[0].endDate == Self.now.addingTimeInterval(10))    // честная дата, не +30

    // awaiting → границ впереди нет → веер вырождается в cancel, не reschedule
    #expect(fx.contains(.cancelNotifications))
    #expect(!fx.contains { if case .rescheduleNotifications = $0 { return true }; return false })
  }

  // Открытие ТИК-В-ТИК на границе (now == boundary): граница включительная (`<=`).
  // Завершившаяся фаза считается, следующая стартует ровно в now с полным временем.
  @Test func exactBoundaryTieCountsPhaseAndStartsNextFresh() {
    let s = runningWork0(auto: true)
    let boundary = Self.now.addingTimeInterval(10)   // ровно граница work(0)

    let (final, fx) = TimerCore.reconciled(s, context: ctx(boundary))

    // work(0) закрыта, перерыв только что начался — ровно в now, с нуля
    #expect(final.phase == .shortBreak(afterIndex: 0))
    #expect(final.currentIntervalStart == boundary)
    #expect(final.remaining(at: boundary) == 5)      // полные 5 сек перерыва впереди

    let saved = savedSessions(fx)
    #expect(saved.count == 1)                        // ровно одна (граница перерыва T+15 строго позже — не трогаем)
    #expect(saved[0].endDate == boundary)
  }

  // Долгое отсутствие в авто: докручивает до .finished и ОСТАНАВЛИВАЕТСЯ.
  // (Регрессия на бесконечный цикл — тест повис бы, а не покраснел.)
  @Test func autoRollsAllTheWayToFinishedAndTerminates() {
    let s = runningWork0(auto: true)
    let (final, fx) = TimerCore.reconciled(s, context: ctx(Self.now.addingTimeInterval(10_000)))

    #expect(final.phase == .finished)
    #expect(savedSessions(fx).count == 2)
  }

  // Граница ещё впереди → догонять нечего → пустой веер, состояние не тронуто.
  @Test func nothingCrossedReturnsUnchangedStateAndNoEffects() {
    let s = runningWork0(auto: true)
    let (final, fx) = TimerCore.reconciled(s, context: ctx(Self.now.addingTimeInterval(5)))  // до границы (+10)

    #expect(final == s)
    #expect(fx.isEmpty)
  }

  // idle → границы нет → цикл не крутится → пустой веер.
  @Test func idleReturnsUnchangedStateAndNoEffects() {
    let s = TimerState(config: Self.config(auto: true))   // phase == .idle
    let (final, fx) = TimerCore.reconciled(s, context: ctx(Self.now.addingTimeInterval(9_999)))

    #expect(final == s)
    #expect(fx.isEmpty)
  }
}
