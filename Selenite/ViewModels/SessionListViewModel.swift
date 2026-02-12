//
//  SessionListViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 05.02.2026.
//

import Foundation
import SwiftData

struct DailySessionGroup: Identifiable {
  let id: Date
  let sessions: [Period]
}

@Observable
final class SessionListViewModel {
  private var modelContext: ModelContext
  
  private(set) var groupedSessions: [DailySessionGroup] = []
  var sessions: [Period] = [] {
    didSet {
      updateGroupedSessions()
    }
  }
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  func fetchSessions() {
    do {
      let descriptor = FetchDescriptor<Period>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
      self.sessions = try modelContext.fetch(descriptor)
    } catch {
      print("Ошибка загрузки сессий: \(error.localizedDescription)")
    }
  }
  
  func deleteAll() {
    do {
      try modelContext.delete(model: Period.self)
      try modelContext.save()
      
      sessions = []
    } catch {
      print("Ошибка пакетного удаления: \(error.localizedDescription)")
    }
  }
  
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
}

extension Date {
  var smartDate: String {
    let calendar = Calendar.current
    
    let isCurrentYear = calendar.component(.year, from: self) == calendar.component(.year, from: Date())
    
    if isCurrentYear {
      return self.formatted(.dateTime.day().month(.abbreviated))
    } else {
      return self.formatted(.dateTime.day().month(.abbreviated).year())
    }
    
  }
}

extension Date {
  var formattedSectionTitle: String {
    let calendar = Calendar.current
    
    if calendar.isDateInToday(self) {
      return "Today"
    } else if calendar.isDateInYesterday(self) {
      return "Yesterday"
    } else {
      return self.smartDate
    }
  }
}
