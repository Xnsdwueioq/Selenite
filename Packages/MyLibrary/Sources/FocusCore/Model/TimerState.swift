// TimerState.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

import Foundation

public struct TimerState: Codable, Sendable, Equatable {
  public var config: TimerConfig
  public var phase: Phase = .idle
  public var completedIndices: Set<Int> = []
  public var sessionTitle: String = "Selenite"
  public var cycleID: UUID?
  public var workedIntervals: [DateInterval] = []
  public var currentIntervalStart: Date?
  
  public init(
    config: TimerConfig,
  ) {
    self.config = config
  }
  
  public var phaseDuration: TimeInterval? {
    return config.duration(of: phase)
  }
  
  public var isPaused: Bool {
    switch phase {
    case .work, .shortBreak, .longBreak:
      return currentIntervalStart == nil
    default:
      return false
    }
  }
  
  /// Оставшееся время `TimeInterval` до истечения
  /// текущей `Phase`
  public func remaining(at now: Date) -> TimeInterval? {
    guard let phaseDuration else { return nil }
    let workedIntervalsDuration = workedIntervals.reduce(0) { $0 + $1.duration }
    var currentIntervalDuration: TimeInterval = 0
    if let currentIntervalStart {
      currentIntervalDuration = now.timeIntervalSince(currentIntervalStart)
    }
    return max(0, phaseDuration - (workedIntervalsDuration + currentIntervalDuration))
  }
  
  /// Конец фазы (`Date`) относительно текущего времени `now`
  public func phaseEnd(at now: Date) -> Date? {
    guard let remainingTime = remaining(at: now),
          !isPaused else { return nil }
    return now.advanced(by: remainingTime)
  }
  
  /// Возвращает конец (`Date`) текущей `Phase`,
  /// без связи с конкретным моментов временем
  var currentBoundaryDate: Date? {
    guard let start = currentIntervalStart, let phaseDuration else { return nil }
    let worked = workedIntervals.reduce(0) { $0 + $1.duration }
    return start.addingTimeInterval(phaseDuration - worked)
  }
}
