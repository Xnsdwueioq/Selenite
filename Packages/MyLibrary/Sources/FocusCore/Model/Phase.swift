// Phase.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

public enum Phase: Codable, Sendable, Equatable {
  case idle
  case work(index: Int)
  case shortBreak(afterIndex: Int)
  case longBreak
  indirect case awaiting(next: Phase)
  case finished
}
