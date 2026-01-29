//
//  SettingsViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import Foundation

@Observable
final class SettingsManager {
  var sessionDuration: Int
  var sessionCount: Int
  var sessionAutostart: Bool
  
  var areBreaksDisabled: Bool
  var shortBreakDuration: Int
  var longBreakDuration: Int
  var breakAutostart: Bool
  
  init(sessionDuration: Int = 25, sessionCount: Int = 4, sessionAutostart: Bool = false, areBreaksDisabled: Bool = false, shortBreakDuration: Int = 5, longBreakDuration: Int = 30, breakAutostart: Bool = false) {
    self.sessionDuration = sessionDuration
    self.sessionCount = sessionCount
    self.sessionAutostart = sessionAutostart
    self.areBreaksDisabled = areBreaksDisabled
    self.shortBreakDuration = shortBreakDuration
    self.longBreakDuration = longBreakDuration
    self.breakAutostart = breakAutostart
  }
}
