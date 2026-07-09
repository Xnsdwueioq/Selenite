// TimerEvent.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

public enum TimerEvent: Sendable, Equatable {
  case start
  case toggle
  case pause, resume
  case skipForward(saveCurrent: Bool)
  case skipBackward(saveCurrent: Bool)
  case restartCycle
  case boundaryReached
  case rename(String)
}
