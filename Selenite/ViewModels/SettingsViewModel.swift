//
//  SettingsViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 14.02.2026.
//

import Foundation
import SwiftData


@Observable
final class SettingsViewModel {
  private var dataService: PeriodDataService
  
  init(modelContext: ModelContext) {
    self.dataService = PeriodDataService(modelContext: modelContext)
  }
  
  func deleteSessionsHistory() {
    do {
      try dataService.deleteAll()
    } catch {
      print("Не удалось удалить историю сессий: \(error.localizedDescription)")
    }
  }
}
