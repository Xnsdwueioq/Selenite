// TimerEffect.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

import Foundation

public enum TimerEffect: Sendable, Equatable {
  case persistSnapshot(TimerState)
  case saveCompleted(CompletedSession)
  case rescheduleNotifications([PhaseBoundary])
  case cancelNotifications
  case syncLiveActivity(TimerState)
  case reloadWidgets
  case pushToWatch(TimerState)
  case addCalendarEvent(CompletedSession)
}
