//
//  TimerTabViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 03.02.2026.
//

import Foundation


@Observable
final class TimerTabViewModel {
  private let settingsManager: SettingsManager
  
  var sessionTitle: String { didSet { sheduleSave() } }
  var sessionDuration: Double { didSet { sheduleSave() } }
  
  init(settingsManager: SettingsManager) {
    self.settingsManager = settingsManager
    self.sessionTitle = settingsManager.sessionTitle
    self.sessionDuration = Double(settingsManager.sessionDuration)
  }
  
  private var saveTask: Task<Void, Never>?
  
  
  private func saveAll() {
    settingsManager.sessionTitle = sessionTitle
    settingsManager.sessionDuration = Int(sessionDuration)
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
