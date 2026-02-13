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
  private let dataService: PeriodDataService
  
  private(set) var groupedSessions: [DailySessionGroup] = []
  var sessions: [Period] = [] {
    didSet {
      updateGroupedSessions()
    }
  }
  
  init(modelContext: ModelContext) {
    self.dataService = PeriodDataService(modelContext: modelContext)
  }
  
  // MARK: - Actions
  
  func fetchAllSessions() {
    do {
      self.sessions = try dataService.fetchAllSessions()
    } catch {
      print("Ошибка загрузки сессий: \(error.localizedDescription)")
    }
  }
  
  func deleteAll() {
    do {
      try dataService.deleteAll()
      sessions = []
    } catch {
      print("Ошибка пакетного удаления: \(error.localizedDescription)")
    }
  }
  
  
  // MARK: - Group Logic
  
  func updateGroupedSessions() {
    let groups = Dictionary(grouping: sessions, by: {
      Calendar.current.startOfDay(for: $0.startDate)
    })
    self.groupedSessions = groups
      .sorted { $0.key > $1.key }
      .map { key, value in
        DailySessionGroup(id: key, sessions: value)
      }
  }
  
  struct DailySessionGroup: Identifiable {
    let id: Date
    let sessions: [Period]
  }
}
