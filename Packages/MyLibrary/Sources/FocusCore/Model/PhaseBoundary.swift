// PhaseBoundary.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

import Foundation

public struct PhaseBoundary: Sendable, Equatable {
  public var endingPhase: Phase
  public var completionAt: Date
  public var nextPhase: Phase
  public var nextPhaseDuration: TimeInterval?
  public var nextPhaseStartsAutomatically: Bool
  
  public init(
    endingPhase: Phase,
    completionAt: Date,
    nextPhase: Phase,
    nextPhaseDuration: TimeInterval?,
    nextPhaseStartsAutomatically: Bool
  ) {
    self.endingPhase = endingPhase
    self.completionAt = completionAt
    self.nextPhase = nextPhase
    self.nextPhaseDuration = nextPhaseDuration
    self.nextPhaseStartsAutomatically = nextPhaseStartsAutomatically
  }
}
