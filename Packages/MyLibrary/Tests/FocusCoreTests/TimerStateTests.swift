// TimerStateTests.swift
// FocusCoreTests
//
// Фокус: currentBoundaryDate — честная (неклампленная) дата конца фазы,
// на которой держится reconcile.

import Foundation
import Testing
@testable import FocusCore

@Suite struct TimerStateTests {

  static let now = Date(timeIntervalSince1970: 1_720_000_000)
  static let config = TimerConfig(
    sessionCount: 4,
    sessionDuration: 25,
    shortBreaksEnabled: true,
    shortBreakDuration: 30,
    longBreaksEnabled: true,
    longBreakDuration: 60
  )

  // Идущая работа: граница = старт + длительность.
  @Test func boundaryIsStartPlusDurationForRunningWork() {
    var s = TimerState(config: Self.config)
    s.phase = .work(index: 0)
    s.currentIntervalStart = Self.now
    #expect(s.currentBoundaryDate == Self.now.addingTimeInterval(25))
  }

  // Учитывает уже отработанные куски (после pause/resume).
  @Test func boundaryAccountsForWorkedIntervals() {
    var s = TimerState(config: Self.config)
    s.phase = .work(index: 0)
    s.workedIntervals = [DateInterval(start: Self.now, end: Self.now.addingTimeInterval(10))]  // 10 сек отработано
    let resumeAt = Self.now.addingTimeInterval(300)
    s.currentIntervalStart = resumeAt
    // осталось 25 − 10 = 15 → граница через 15 сек от возобновления
    #expect(s.currentBoundaryDate == resumeAt.addingTimeInterval(15))
  }

  // На паузе якоря нет → границы нет.
  @Test func boundaryIsNilWhenPaused() {
    var s = TimerState(config: Self.config)
    s.phase = .work(index: 0)
    s.workedIntervals = [DateInterval(start: Self.now, end: Self.now.addingTimeInterval(10))]
    s.currentIntervalStart = nil
    #expect(s.isPaused)
    #expect(s.currentBoundaryDate == nil)
  }

  // idle / awaiting / finished — фаза не тикает, границы нет.
  @Test func boundaryIsNilForNonRunningPhases() {
    let idle = TimerState(config: Self.config)
    #expect(idle.currentBoundaryDate == nil)

    var awaiting = TimerState(config: Self.config)
    awaiting.phase = .awaiting(next: .shortBreak(afterIndex: 0))
    #expect(awaiting.currentBoundaryDate == nil)

    var finished = TimerState(config: Self.config)
    finished.phase = .finished
    #expect(finished.currentBoundaryDate == nil)
  }

  // КЛЮЧЕВОЕ отличие от phaseEnd — ради чего свойство и заведено:
  // за границей phaseEnd зажимается в now, а currentBoundaryDate держит честную дату в прошлом.
  @Test func boundaryStaysInPastWhilePhaseEndClamps() {
    var s = TimerState(config: Self.config)
    s.phase = .work(index: 0)
    s.currentIntervalStart = Self.now                  // граница = now + 25
    let past = Self.now.addingTimeInterval(100)        // «сейчас» уже за границей

    #expect(s.currentBoundaryDate == Self.now.addingTimeInterval(25))  // не зависит от now
    #expect(s.phaseEnd(at: past) == past)                              // зажат в now — для reconcile бесполезен
  }
}
