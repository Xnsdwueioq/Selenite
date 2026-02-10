//
//  SessionEditViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 10.02.2026.
//

import Foundation
import SwiftData


struct PeriodIntervalDraft: Identifiable {
  let persistentModelID: PersistentIdentifier
  var id: PersistentIdentifier { persistentModelID }
  var startTime: Date
  var endTime: Date?
  
  var duration: TimeInterval {
    startTime.distance(to: endTime ?? Date())
  }
  
  init(from model: PeriodInterval) {
    self.persistentModelID = model.persistentModelID
    self.startTime = model.startTime
    self.endTime = model.endTime
  }
}

struct PeriodDraft {
  var title: String
  var fragmentedType: FragmentedType
  var startDate: Date
  var intervals: [PeriodIntervalDraft]
  
  var periodDuration: TimeInterval {
    intervals.reduce(into: 0) { total, interval in
      total += interval.duration
    }
  }
  
  var calculateFragmentedType: FragmentedType {
    switch intervals.count {
    case 1: return FragmentedType.solid
    default: return FragmentedType.fragmented
    }
  }
  
  init(from model: Period) {
    self.title = model.title
    self.fragmentedType = model.fragmentedType
    self.startDate = model.startDate
    self.intervals = model.intervals.map { PeriodIntervalDraft(from: $0) }
  }
}

@Observable
final class SessionEditViewModel {
  private var modelContext: ModelContext
  private var session: Period
  
  var draftSession: PeriodDraft
  
  init(modelContext: ModelContext, session: Period) {
    self.modelContext = modelContext
    self.session = session
    self.draftSession = PeriodDraft(from: session)
  }
  
  func deleteSession() {
    modelContext.delete(session)
  }
  
  func saveChanges() {
    session.title = draftSession.title
    
    for intervalDraft in draftSession.intervals {
      if let originalInterval = session.intervals.first(where: { $0.persistentModelID == intervalDraft.persistentModelID }) {
        originalInterval.startTime = intervalDraft.startTime
        originalInterval.endTime = intervalDraft.endTime
      }
    }
    
    try? modelContext.save()
  }
  
  func getFormattedDuration() -> String {
    draftSession.formattedDuration
  }
  
  func getPeriodDraftIntervals() -> [PeriodIntervalDraft] {
    return draftSession.intervals
  }
}


// MARK: - Extensions

extension PeriodDraft {
  var formattedDuration: String {
    let duration = Duration.seconds(periodDuration)
    return duration.formatted(
      .units(allowed: [.hours, .minutes], width: .abbreviated)
    )
  }
}
