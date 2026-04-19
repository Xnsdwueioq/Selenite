//
//  StatisticsViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 20.04.2026.
//

import Foundation
import SwiftData

@Observable
final class StatisticsViewModel {
  private var dataService: PeriodDataService
  
  init(
    modelContext: ModelContext
  ) {
    self.dataService = PeriodDataService(modelContext: modelContext)
    
    try? self.sessions = dataService.fetchAllSessions()
  }
  
  // MARK: - Sessions
  
  private var sessions: [Period] = []
  
  var filteredSessions: [Period] {
    let calendar = Calendar.current
    let now = Date()
    
    return sessions.filter { session in
      switch selectedTimeRange {
      case .day:
        return calendar.isDate(session.startDate, inSameDayAs: now)
      case .week:
        return calendar.isDate(session.startDate, equalTo: now, toGranularity: .weekOfYear)
      case .month:
        return calendar.isDate(session.startDate, equalTo: now, toGranularity: .month)
      case .year:
        return calendar.isDate(session.startDate, equalTo: now, toGranularity: .year)
      case .allTime:
        return true
      }
    }
  }
  
  var selectedTimeRange: TimeRange = .week
  
  enum TimeRange: String, CaseIterable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"
    case allTime = "Все время"
  }
}
