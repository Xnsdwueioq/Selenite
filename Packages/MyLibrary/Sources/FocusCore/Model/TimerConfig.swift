// TimerConfig.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

import Foundation

public struct TimerConfig: Codable, Sendable, Equatable {
  public var sessionCount: Int
  public var sessionDuration: TimeInterval
  public var shortBreaksEnabled: Bool
  public var shortBreakDuration: TimeInterval
  public var longBreaksEnabled: Bool
  public var longBreakDuration: TimeInterval
  public var autoAdvance: Bool = false
  
  public init(
    sessionCount: Int,
    sessionDuration: TimeInterval,
    shortBreaksEnabled: Bool,
    shortBreakDuration: TimeInterval,
    longBreaksEnabled: Bool,
    longBreakDuration: TimeInterval,
    autoAdvance: Bool = false
  ) {
    self.sessionCount = sessionCount
    self.sessionDuration = sessionDuration
    self.shortBreaksEnabled = shortBreaksEnabled
    self.shortBreakDuration = shortBreakDuration
    self.longBreaksEnabled = longBreaksEnabled
    self.longBreakDuration = longBreakDuration
    self.autoAdvance = autoAdvance
  }
}

extension TimerConfig {
  func duration(of phase: Phase) -> TimeInterval? {
    switch phase {
    case .work:               return self.sessionDuration
    case .shortBreak:         return self.shortBreakDuration
    case .longBreak:          return self.longBreakDuration
    case .awaiting(let next): return duration(of: next)
    case .idle, .finished:    return nil
    }
  }
}
