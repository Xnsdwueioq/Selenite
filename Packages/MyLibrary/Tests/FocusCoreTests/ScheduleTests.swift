// ScheduleTests.swift
// FocusCoreTests

import Foundation
import Testing
@testable import FocusCore

@Suite struct ScheduleTests {

  static let now = Date(timeIntervalSince1970: 1_720_000_000)

  // MARK: - Ручной режим: одна ближайшая граница

  @Test func manualModeRunningWorkReturnsSingleClosestBoundary() {
    var cfg = TimerConfig(
      sessionCount: 4,
      sessionDuration: 25,
      shortBreaksEnabled: true,
      shortBreakDuration: 30,
      longBreaksEnabled: true,
      longBreakDuration: 60
    )
    cfg.autoAdvance = false
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now

    // считаем через 10 сек после старта — 15 сек ещё осталось
    let boundaries = Schedule.boundaries(for: state, now: Self.now.addingTimeInterval(10))

    #expect(boundaries == [
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(25), nextPhase: .shortBreak(afterIndex: 0))
    ])
  }

  // Граница границы не зависит от того, в какой момент "now" её считать —
  // только от якоря старта и полной длительности фазы.
  @Test func closestBoundaryIsIndependentOfEvaluationMoment() {
    var cfg = TimerConfig(
      sessionCount: 4, sessionDuration: 25,
      shortBreaksEnabled: true, shortBreakDuration: 30,
      longBreaksEnabled: true, longBreakDuration: 60
    )
    cfg.autoAdvance = false
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now

    let early = Schedule.boundaries(for: state, now: Self.now.addingTimeInterval(1))
    let late = Schedule.boundaries(for: state, now: Self.now.addingTimeInterval(24))

    #expect(early.first?.completionAt == Self.now.addingTimeInterval(25))
    #expect(late.first?.completionAt == Self.now.addingTimeInterval(25))
  }

  // Уже закрытые куски (после pause/resume) тоже учитываются в remaining.
  @Test func manualModeAccountsForClosedWorkedIntervals() {
    var cfg = TimerConfig(
      sessionCount: 4, sessionDuration: 25,
      shortBreaksEnabled: true, shortBreakDuration: 30,
      longBreaksEnabled: true, longBreakDuration: 60
    )
    cfg.autoAdvance = false
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.workedIntervals = [DateInterval(start: Self.now, end: Self.now.addingTimeInterval(5))]  // 5 сек уже отработано
    let resumeAt = Self.now.addingTimeInterval(300)
    state.currentIntervalStart = resumeAt

    let boundaries = Schedule.boundaries(for: state, now: resumeAt)

    // осталось 25 - 5 = 20 сек от момента возобновления
    #expect(boundaries == [
      PhaseBoundary(completionAt: resumeAt.addingTimeInterval(20), nextPhase: .shortBreak(afterIndex: 0))
    ])
  }

  // MARK: - Пустой план

  @Test func pausedReturnsEmptyPlan() {
    var cfg = TimerConfig(
      sessionCount: 4, sessionDuration: 25,
      shortBreaksEnabled: true, shortBreakDuration: 30,
      longBreaksEnabled: true, longBreakDuration: 60
    )
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.workedIntervals = [DateInterval(start: Self.now, end: Self.now.addingTimeInterval(10))]
    state.currentIntervalStart = nil   // на паузе
    #expect(state.isPaused)

    #expect(Schedule.boundaries(for: state, now: Self.now.addingTimeInterval(9_999)) == [])

    // и в авто-режиме пауза тоже даёт пустой план
    cfg.autoAdvance = true
    state.config = cfg
    #expect(Schedule.boundaries(for: state, now: Self.now.addingTimeInterval(9_999)) == [])
  }

  @Test func idleReturnsEmptyPlan() {
    let state = TimerState(config: Self.smallConfig)
    #expect(Schedule.boundaries(for: state, now: Self.now) == [])
  }

  @Test func finishedReturnsEmptyPlan() {
    var state = TimerState(config: Self.smallConfig)
    state.phase = .finished
    #expect(Schedule.boundaries(for: state, now: Self.now) == [])
  }

  @Test func awaitingReturnsEmptyPlan() {
    var state = TimerState(config: Self.smallConfig)
    state.phase = .awaiting(next: .shortBreak(afterIndex: 0))
    #expect(Schedule.boundaries(for: state, now: Self.now) == [])
  }

  // MARK: - Авто-режим: цепочка границ до .finished

  static var smallConfig: TimerConfig {
    var cfg = TimerConfig(
      sessionCount: 2,
      sessionDuration: 25,
      shortBreaksEnabled: true,
      shortBreakDuration: 30,
      longBreaksEnabled: true,
      longBreakDuration: 60
    )
    cfg.autoAdvance = true
    return cfg
  }

  // work(0) → shortBreak(0) → work(1) → longBreak → finished
  @Test func autoModeChainsThroughFullCycle() {
    var state = TimerState(config: Self.smallConfig)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now

    let boundaries = Schedule.boundaries(for: state, now: Self.now)

    #expect(boundaries == [
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(25), nextPhase: .shortBreak(afterIndex: 0)),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(55), nextPhase: .work(index: 1)),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(80), nextPhase: .longBreak),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(140), nextPhase: .finished),
    ])
  }

  // Та же цепочка, но старт не с work(0), а из середины цикла (идущий короткий перерыв).
  @Test func autoModeChainsFromMidCycleShortBreak() {
    var state = TimerState(config: Self.smallConfig)
    state.phase = .shortBreak(afterIndex: 0)
    state.currentIntervalStart = Self.now

    let boundaries = Schedule.boundaries(for: state, now: Self.now)

    #expect(boundaries == [
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(30), nextPhase: .work(index: 1)),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(55), nextPhase: .longBreak),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(115), nextPhase: .finished),
    ])
  }

  // Короткие перерывы выключены: цепочка идёт work → work напрямую.
  @Test func autoModeSkipsDisabledShortBreaks() {
    var cfg = TimerConfig(
      sessionCount: 3, sessionDuration: 10,
      shortBreaksEnabled: false, shortBreakDuration: 30,
      longBreaksEnabled: true, longBreakDuration: 20
    )
    cfg.autoAdvance = true
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now

    let boundaries = Schedule.boundaries(for: state, now: Self.now)

    #expect(boundaries == [
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(10), nextPhase: .work(index: 1)),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(20), nextPhase: .work(index: 2)),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(30), nextPhase: .longBreak),
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(50), nextPhase: .finished),
    ])
  }

  // Длинный перерыв выключен: последняя сессия ведёт сразу в .finished,
  // и цикл не продолжает добавлять границы после этого.
  @Test func autoModeEndsImmediatelyWhenLongBreakDisabled() {
    var cfg = TimerConfig(
      sessionCount: 1, sessionDuration: 15,
      shortBreaksEnabled: true, shortBreakDuration: 30,
      longBreaksEnabled: false, longBreakDuration: 60
    )
    cfg.autoAdvance = true
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now

    let boundaries = Schedule.boundaries(for: state, now: Self.now)

    #expect(boundaries == [
      PhaseBoundary(completionAt: Self.now.addingTimeInterval(15), nextPhase: .finished)
    ])
  }

  // Регрессия на баг зависания: цепочка должна закончиться собственными силами,
  // не полагаясь на внешний таймаут теста.
  @Test func autoModeChainTerminatesInsteadOfLoopingForever() {
    var state = TimerState(config: Self.smallConfig)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now

    let boundaries = Schedule.boundaries(for: state, now: Self.now)

    #expect(boundaries.last?.nextPhase == .finished)
    #expect(boundaries.count == 4)
  }
}
