//
//  CalendarSyncViewModel.swift
//  Drafts
//
//  Created by Eyhciurmrn Zmpodackrl on 04.04.2026.
//


import Foundation
import EventKit
import SwiftUI

@Observable
final class CalendarSyncViewModel {
  private let appSettings: AppSettings
  private let appCoordinator: AppCoordinator
  
  private let eventKitManager: EventKitManager
  private let calendarService: CalendarService
  
  var hasFullAccess: Bool {
    eventKitManager.authrorizationStatus == .fullAccess
  }
  
  var calendarsToDisplay: [CalendarItem] {
    calendarService.availableCalendars
  }
  
  init(
    eventKitManager: EventKitManager = EventKitManager.shared,
    appSettings: AppSettings,
    appCoordinator: AppCoordinator,
    calendarService: CalendarService
  ) {
    self.eventKitManager = eventKitManager
    self.appSettings = appSettings
    self.appCoordinator = appCoordinator
    self.calendarService = calendarService
        
    calendarService.repickCalendar()
  }
  
  // MARK: - Additional Screens Logic
    
  var isCalendarSelected: Bool {
    get {
      appCoordinator.settingsCoordindator.isCalendarSelected
    }
    set {
      appCoordinator.settingsCoordindator.isCalendarSelected = newValue
    }
  }
  
  var isCalendarCreated: Bool {
    get {
      appCoordinator.settingsCoordindator.isCalendarCreated
    }
    set {
      appCoordinator.settingsCoordindator.isCalendarCreated = newValue
    }
  }
  
  func openCalendarSelectionSheet() {
    isCalendarSelected = true
  }
  
  func openCalendarCreationSheet() {
    isCalendarCreated = true
  }
  
  
  // MARK: - Calendar Creation
  
  var newCalendarTitle = ""
  var newCalendarColor = Color.purpleBrand
  var isNewCalendarTitleValidate: Bool {
    let trimmedTitle = newCalendarTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    return !trimmedTitle.isEmpty
  }
  
  private func resetNewCalendarData() {
    newCalendarTitle = ""
    newCalendarColor = Color.purpleBrand
  }
  
  func creationCalendarAction() {
    let createdCalendarId = calendarService.createCalendar(title: newCalendarTitle, color: newCalendarColor)
    isCalendarCreated = false
    isCalendarSelected = true
    resetNewCalendarData()
    
    if let createdCalendarId {
      calendarService.pickCalendar(with: createdCalendarId)
    }
  }
  
  // MARK: - Calendar Selection
  
  var pickedCalendarID: String? {
    get {
      appSettings.selectedCalendar?.id
    }
    set {
      guard let newId = newValue,
            newId != appSettings.selectedCalendar?.id else {
        return
      }
      calendarService.pickCalendar(with: newId)
    }
  }
  
  // MARK: - Sync Toggle Logic
  
  var isSynchronizeOn: Bool {
    get {
      appSettings.synchronizeCalendar
    }
    set {
      guard isSynchronizeOn != newValue else { return }
      if !newValue {
        appSettings.synchronizeCalendar = false
      } else {
        appSettings.synchronizeCalendar = handleSyncTurnedOn()
      }
    }
  }
  
  @MainActor
  private func handleSyncTurnedOn() -> Bool {
    let status = eventKitManager.authrorizationStatus
    
    switch status {
    case .fullAccess:
      if appSettings.selectedCalendar == nil {
        isCalendarSelected = true
      }
      return true
      
    case .notDetermined:
      Task {
        do {
          let granted = try await eventKitManager.requestAccess()
          if granted {
            if appSettings.selectedCalendar == nil {
              isCalendarSelected = true
            }
            return true
          } else {
            appCoordinator.selectedAlert = .noAccessToCalendar
            return false
          }
        } catch {
          print("Ошибка доступа: \(error.localizedDescription)")
          return false
        }
      }
      
    case .denied, .restricted, .writeOnly:
      appCoordinator.selectedAlert = .noAccessToCalendar
      return false
      
    @unknown default:
      return false
    }
    
    return false
  }
}
