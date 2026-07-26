//
//  TimerConfig+Default.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import FocusCore

extension TimerConfig {
  static let `default` = TimerConfig(
    sessionCount: 4,
    sessionDuration: 6,
    shortBreaksEnabled: true,
    shortBreakDuration: 5,
    longBreaksEnabled: true,
    longBreakDuration: 30,
    autoAdvance: false
  )
}
