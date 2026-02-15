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

private struct PeriodDraft {
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
  private let dataService: PeriodDataService
  
  private var session: Period
  
  init(modelContext: ModelContext, session: Period) {
    self.dataService = PeriodDataService(modelContext: modelContext)
    
    self.session = session
    self.draftSession = PeriodDraft(from: session)
  }
  
  
  // MARK: - Draft Session
  
  private var draftSession: PeriodDraft
  
  var draftSessionTitle: String {
    get { draftSession.title }
    set { draftSession.title = newValue }
  }
  
  var draftIntervals: [PeriodIntervalDraft] {
    get { draftSession.intervals }
    set { draftSession.intervals = newValue }
  }
  
  func resetTitle() {
    draftSession.title = session.title
  }
  
  var isChangesSaved: Bool {
    guard draftSession.title == session.title else { return false }
    guard draftSession.intervals.count == session.intervals.count else { return false }
    
    return zip(draftSession.intervals, session.intervals).allSatisfy { draft, original in
      draft.startTime == original.startTime && draft.endTime == original.endTime
    }
  }
  
  func getFormattedDuration() -> String {
    draftSession.formattedDuration
  }
  
  // MARK: - Actions
  func deleteSession() {
    do {
      try dataService.delete(session)
    } catch {
      print("Ошибка удаления сессии: \(error.localizedDescription)")
    }
  }
  
  func saveChanges() -> Bool {
    guard let validTitle = draftSessionTitle.validTitle else {
      return false
    }
    
    session.title = validTitle
    
    for intervalDraft in draftSession.intervals {
      if let originalInterval = session.intervals.first(where: { $0.persistentModelID == intervalDraft.persistentModelID }) {
        originalInterval.startTime = intervalDraft.startTime
        originalInterval.endTime = intervalDraft.endTime
      }
    }
    
    do {
      try dataService.save()
      return true
    } catch {
      print("Не удалось сохранить изменения: \(error.localizedDescription)")
      return false
    }
  }
}

private extension PeriodDraft {
  var formattedDuration: String {
    let duration = Duration.seconds(periodDuration)
    return duration.formatted(
      .units(allowed: [.hours, .minutes], width: .abbreviated)
    )
  }
}
