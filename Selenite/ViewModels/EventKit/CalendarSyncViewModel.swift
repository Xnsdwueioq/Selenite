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
    
    self._isSynchronizeOn = appSettings.synchronizeCalendar
    
    repickCalendar()
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
      pickCalendar(with: createdCalendarId)
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
      pickCalendar(with: newId)
    }
  }
  
  var selectedCalendarColorView: Color {
    guard let selectedCalendar = appSettings.selectedCalendar else {
      return Color.white.opacity(0)
    }
    return Color(cgColor: selectedCalendar.color)
  }
  
  var selectedCalendarTitleView: String {
    guard let selectedCalendar = appSettings.selectedCalendar else {
      return "Не выбран"
    }
    return selectedCalendar.title
  }
  
  func onCalendarsChangedAction() {
    print("[SettingsTabViewModel][onCalendarsChangedAction] was called")
    guard let pickedCalendarID,
          let selectedEKCalendarActual = calendarService.findCalendar(with: pickedCalendarID),
          let selectedCalendar = appSettings.selectedCalendar else {
      return
    }
    
    let selectedCalendarActual = CalendarItem(from: selectedEKCalendarActual)
    if selectedCalendarActual.hashValue != selectedCalendar.hashValue {
      repickCalendar()
    }
  }
  
  func repickCalendar() {
    print("[SettingsTabViewModel][repickCalendar] was called")
    guard let currentId = pickedCalendarID else {
      return
    }
    pickCalendar(with: currentId)
  }
  
  private func pickCalendar(with id: String) {
    print("[SettingsTabViewModel][pickCalendar] was called")
    guard let selectedCalendar = calendarService.findCalendar(with: id) else {
      print("Can't select a calendar because it can't be found by calendarIdentifier via the CalendarService. AppSettings.selectedCalendar became equal to nil.")
      appSettings.selectedCalendar = nil
    
      return
    }
    appSettings.selectedCalendar = CalendarItem(from: selectedCalendar)
  }
  
  
  // MARK: - Sync Toggle Logic
  
  var isSynchronizeOn: Bool = false {
    didSet {
      guard isSynchronizeOn != oldValue else { return }
      if !isSynchronizeOn {
        appSettings.synchronizeCalendar = false
      } else {
        handleSyncTurnedOn()
      }
    }
  }
  
  @MainActor
  private func handleSyncTurnedOn() {
    let status = eventKitManager.authrorizationStatus
    
    switch status {
    case .fullAccess:
      appSettings.synchronizeCalendar = true
      if appSettings.selectedCalendar == nil {
        isCalendarSelected = true
      }
      
    case .notDetermined:
      Task {
        do {
          let granted = try await eventKitManager.requestAccess()
          if granted {
            self.appSettings.synchronizeCalendar = true
            self.isSynchronizeOn = true
          } else {
            self.isSynchronizeOn = false
              appCoordinator.selectedAlert = .noAccessToCalendar
          }
        } catch {
          self.isSynchronizeOn = false
          print("Ошибка доступа: \(error.localizedDescription)")
        }
      }
      
    case .denied, .restricted, .writeOnly:
      self.isSynchronizeOn = false
      appCoordinator.selectedAlert = .noAccessToCalendar
      
    @unknown default:
      self.isSynchronizeOn = false
    }
  }
}
