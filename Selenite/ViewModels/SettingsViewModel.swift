//
//  SettingsViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 30.01.2026.
//

import Foundation

@Observable
final class SettingsViewModel {
  private let settingsManager: SettingsManager
  
  var sessionDuration: Double { didSet { sheduleSave() } }
  var sessionCount: Double { didSet { sheduleSave() } }
  var sessionAutostart: Bool { didSet { sheduleSave() } }
  
  var areBreaksDisabled: Bool { didSet { sheduleSave() } }
  var shortBreakDuration: Double { didSet { sheduleSave() } }
  var longBreakDuration: Double { didSet { sheduleSave() } }
  var breakAutostart: Bool { didSet { sheduleSave() } }
  
  private var saveTask: Task<Void, Never>?
  
  init(settingsManager: SettingsManager) {
    self.settingsManager = settingsManager
    
    self.sessionDuration = Double(settingsManager.sessionDuration)
    self.sessionCount = Double(settingsManager.sessionCount)
    self.sessionAutostart = settingsManager.sessionAutostart
    
    self.areBreaksDisabled = settingsManager.areBreaksDisabled
    self.shortBreakDuration = Double(settingsManager.shortBreakDuration)
    self.longBreakDuration = Double(settingsManager.longBreakDuration)
    self.breakAutostart = settingsManager.breakAutostart
  }
  
  private func saveAll() {
    settingsManager.sessionDuration = Int(sessionDuration)
    settingsManager.sessionCount = Int(sessionCount)
    settingsManager.sessionAutostart = sessionAutostart
    
    settingsManager.areBreaksDisabled = areBreaksDisabled
    settingsManager.shortBreakDuration = Int(shortBreakDuration)
    settingsManager.longBreakDuration = Int(longBreakDuration)
    settingsManager.breakAutostart = breakAutostart
    
    print("DEBUG: Settings saved successfully!")
  }
  
  private func sheduleSave() {
    saveTask?.cancel()
    saveTask = Task {
      try? await Task.sleep(for: .seconds(1))
      
      if !Task.isCancelled {
        await MainActor.run {
          saveAll()
        }
      }
    }
  }
}
