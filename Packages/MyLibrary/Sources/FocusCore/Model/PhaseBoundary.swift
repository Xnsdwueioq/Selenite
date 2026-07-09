// PhaseBoundary.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

import Foundation

public struct PhaseBoundary: Sendable, Equatable {
  public var completionAt: Date
  public var nextPhase: Phase
  
  public init(completionAt: Date, nextPhase: Phase) {
    self.completionAt = completionAt
    self.nextPhase = nextPhase
  }
}
