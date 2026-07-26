//
//  TimerDisplay.swift
//  FocusCore
//
//  Created by Eyhciurmrn Zmpodackrl on 7/26/26.
//

import Foundation

public enum ClockReading: Sendable, Equatable {
  case counting(until: Date)
  case frozen(TimeInterval)
  case upcoming(TimeInterval)
  case done
}

public enum TimerDisplay {
  public static func reading(for state: TimerState) -> ClockReading {
    switch state.phase {
    case .idle:
      return .upcoming(state.config.sessionDuration)
    case .awaiting(let next):
      return .upcoming(state.config.duration(of: next) ?? 0)
    case .finished:
      return .done
    case .work, .shortBreak, .longBreak:
      if let boundary = state.currentBoundaryDate {
        return .counting(until: boundary)
      }
      return .frozen(state.frozenRemaining ?? 0)
    }
  }
}
