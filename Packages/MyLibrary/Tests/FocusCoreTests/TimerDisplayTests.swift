// TimerDisplayTests.swift
// FocusCoreTests

import Foundation
import Testing
@testable import FocusCore

@Suite struct TimerDisplayTests {

  static let now = Date(timeIntervalSince1970: 1_720_000_000)
  static let config = TimerConfig(
    sessionCount: 4,
    sessionDuration: 25,
    shortBreaksEnabled: true,
    shortBreakDuration: 30,
    longBreaksEnabled: true,
    longBreakDuration: 60
  )

  // idle — полная первая сессия впереди, не 00:00
  @Test func idleIsUpcomingFullSession() {
    let idle = TimerState(config: Self.config)
    #expect(TimerDisplay.reading(for: idle) == .upcoming(25))
  }

  // awaiting — полная длительность ПРЕДСТОЯЩЕЙ фазы (ТЗ 5.1)
  @Test func awaitingIsUpcomingNextPhase() {
    var awaiting = TimerState(config: Self.config)
    awaiting.phase = .awaiting(next: .shortBreak(afterIndex: 0))
    #expect(TimerDisplay.reading(for: awaiting) == .upcoming(30))
  }

  // идущая — тикает от границы, число не схлопнуто
  @Test func runningIsCountingUntilBoundary() {
    var running = TimerState(config: Self.config)
    running.phase = .work(index: 0)
    running.currentIntervalStart = Self.now
    #expect(TimerDisplay.reading(for: running) == .counting(until: Self.now.addingTimeInterval(25)))
  }

  // пауза — замороженный остаток
  @Test func pausedIsFrozenRemainder() {
    var paused = TimerState(config: Self.config)
    paused.phase = .work(index: 0)
    paused.workedIntervals = [DateInterval(start: Self.now, end: Self.now.addingTimeInterval(10))]
    paused.currentIntervalStart = nil
    #expect(TimerDisplay.reading(for: paused) == .frozen(15))
  }

  // finished — done, а не молчаливый ноль
  @Test func finishedIsDone() {
    var finished = TimerState(config: Self.config)
    finished.phase = .finished
    #expect(TimerDisplay.reading(for: finished) == .done)
  }
}
