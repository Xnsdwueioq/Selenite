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
  
  public var isRunning: Bool {
    currentBoundaryDate != nil
  }
  
  /// Суммарная длительность уже закрытых кусков текущей `Phase`
  private var workedTotal: TimeInterval {
    workedIntervals.reduce(0) { $0 + $1.duration }
  }

  /// Оставшееся время `TimeInterval` до истечения
  /// текущей `Phase`
  ///
  /// Не может быть меньше 0
  public func remaining(at now: Date) -> TimeInterval? {
    guard let phaseDuration else { return nil }
    var currentIntervalDuration: TimeInterval = 0
    if let currentIntervalStart {
      currentIntervalDuration = now.timeIntervalSince(currentIntervalStart)
    }
    return max(0, phaseDuration - (workedTotal + currentIntervalDuration))
  }

  /// Оставшееся время замороженной (на паузе) `Phase` — не зависит от `now`
  public var frozenRemaining: TimeInterval? {
    guard let phaseDuration else { return nil }
    return max(0, phaseDuration - workedTotal)
  }

  /// Возвращает конец (`Date`) текущей `Phase`
  public var currentBoundaryDate: Date? {
    guard let start = currentIntervalStart, let phaseDuration else { return nil }
    return start.addingTimeInterval(phaseDuration - workedTotal)
  }
}
