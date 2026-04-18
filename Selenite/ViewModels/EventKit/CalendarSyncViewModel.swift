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
  private let settingsManager: SettingsManager
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
    settingsManager: SettingsManager = SettingsManager.shared,
    eventKitManager: EventKitManager = EventKitManager.shared,
    appCoordinator: AppCoordinator,
    calendarService: CalendarService
  ) {
    self.settingsManager = settingsManager
    self.appCoordinator = appCoordinator
    self.eventKitManager = eventKitManager
    self.calendarService = calendarService
    
    self._isSynchronizeOn = settingsManager.synchronizeCalendar
    
    repickCalendar()
    processNilCalendar()
  }
  
  func checkAuthorisationStatus() {
    print("[SettingsTabViewModel][checkAuthorizationStatus] was called")
    if isSynchronizeOn && !hasFullAccess {
      isSynchronizeOn = false
      appCoordinator.selectedAlert = .noAccessToCalendar
    }
  }
  
  func processNilCalendar() {
    if isSynchronizeOn && hasFullAccess && settingsManager.selectedCalendar == nil {
      appCoordinator.selectedAlert = .nilCalendarSelected
    }
  }
  
  // MARK: - Additional Screens Logic
  
  var isCalendarSelected = false
  
  func onDismissCalendarSelected() {
    if !isCalendarCreated && settingsManager.selectedCalendar == nil {
      isSynchronizeOn = false
    }
  }
  
  func openCalendarSelectionSheet() {
    isCalendarSelected = true
  }
  
  var isCalendarCreated = false
  
  func onDismissCalendarCreated() {
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
      settingsManager.selectedCalendar?.id
    }
    set {
      guard let newId = newValue,
            newId != settingsManager.selectedCalendar?.id else {
        return
      }
      pickCalendar(with: newId)
    }
  }
  
  var selectedCalendarColorView: Color {
    guard let selectedCalendar = settingsManager.selectedCalendar else {
      return Color.white.opacity(0)
    }
    return Color(cgColor: selectedCalendar.color)
  }
  
  var selectedCalendarTitleView: String {
    guard let selectedCalendar = settingsManager.selectedCalendar else {
      return "Не выбран"
    }
    return selectedCalendar.title
  }
  
  func onCalendarsChangedAction() {
    print("[SettingsTabViewModel][onCalendarsChangedAction] was called")
    guard let pickedCalendarID,
          let selectedEKCalendarActual = calendarService.findCalendar(with: pickedCalendarID),
          let selectedCalendar = settingsManager.selectedCalendar else {
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
      settingsManager.selectedCalendar = nil
      
      processNilCalendar()

      return
    }
    settingsManager.selectedCalendar = CalendarItem(from: selectedCalendar)
  }
  
  
  // MARK: - Sync Toggle Logic
  
  var isSynchronizeOn: Bool = false {
    didSet {
      if isSynchronizeOn == oldValue { return }
      if !isSynchronizeOn {
        settingsManager.synchronizeCalendar = false
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
      settingsManager.synchronizeCalendar = true
      if settingsManager.selectedCalendar == nil {
        isCalendarSelected = true
      }
      
    case .notDetermined:
      Task {
        do {
          let granted = try await eventKitManager.requestAccess()
          if granted {
            self.settingsManager.synchronizeCalendar = true
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
