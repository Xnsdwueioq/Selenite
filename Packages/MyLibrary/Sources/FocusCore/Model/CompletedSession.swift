// CompletedSession.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

import Foundation

public struct CompletedSession: Sendable, Equatable {
  public var title: String
  public var startDate: Date? {
    return workedIntervals.first?.start
  }
  public var endDate: Date? {
    return workedIntervals.last?.end
  }
  public var duration: TimeInterval {
    return workedIntervals.reduce(0) { $0 + $1.duration }
  }
  public var plannedDuration: TimeInterval
  public var totalPauseDuration: TimeInterval {
    guard let startDate, let endDate else { return 0 }
    return (startDate.distance(to: endDate)) - duration
  }
  public var pauseCount: Int {
    return max(0, workedIntervals.count - 1)
  }
  public var terminationReason: TerminationReason
  public var sessionIndex: Int
  public var workedIntervals: [DateInterval]
  public var cycleID: UUID
  
  public init(
    title: String,
    plannedDuration: TimeInterval,
    terminationReason: TerminationReason,
    sessionIndex: Int,
    workedIntervals: [DateInterval],
    cycleID: UUID
  ) {
    self.title = title
    self.plannedDuration = plannedDuration
    self.terminationReason = terminationReason
    self.sessionIndex = sessionIndex
    self.workedIntervals = workedIntervals
    self.cycleID = cycleID
  }
}

extension CompletedSession {
  /// Фабрика, которая создает `CompletedSession`
  /// Получает `workedIntervals` из `timerState`
  static func create(
    from timerState: TimerState,
    with cycleID: UUID,
    terminationReason: TerminationReason,
    sessionIndex: Int
  ) -> CompletedSession {
    return CompletedSession(
      title: timerState.sessionTitle,
      plannedDuration: timerState.config.sessionDuration,
      terminationReason: terminationReason,
      sessionIndex: sessionIndex,
      workedIntervals: timerState.workedIntervals,
      cycleID: cycleID
    )
  }
}
