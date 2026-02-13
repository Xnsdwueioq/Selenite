//
//  PeriodDataService.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 13.02.2026.
//

import Foundation
import SwiftData


final class PeriodDataService {
  private let modelContext: ModelContext
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  
  // MARK: - Fetching
  
  func fetchAllSessions() throws -> [Period] {
    let descriptor = FetchDescriptor<Period>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
    return try modelContext.fetch(descriptor)
  }
  
  
  // MARK: - Saving
  
  func save() throws {
    try modelContext.save()
  }
  
  // MARK: - Deleting
  
  func deleteAll() throws {
    try modelContext.delete(model: Period.self)
    try save()
  }
  
  func delete(_ period: Period) throws {
    modelContext.delete(period)
    try save()
  }
}
