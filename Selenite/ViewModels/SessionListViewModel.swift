//
//  SessionListViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 05.02.2026.
//

import Foundation
import SwiftData

@Observable
final class SessionListViewModel {
  private var modelContext: ModelContext
  var sessions: [Period] = []
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  // MARK: Fetch
  func fetchSessions() {
    do {
      let descriptor = FetchDescriptor<Period>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
      
      self.sessions = try modelContext.fetch(descriptor)
      
    } catch {
      print("Ошибка загрузки сессий: \(error.localizedDescription)")
    }
  }
}
