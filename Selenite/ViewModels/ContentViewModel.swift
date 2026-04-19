//
//  ContentViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 19.04.2026.
//

import Foundation
import EventKit

@Observable
final class ContentViewModel {
  var eventKitManager: EventKitManager
  var appCoordinator: AppCoordinator
  var appSettings: AppSettings
  var calendarService: CalendarService?
  
  private var eventStoreChangedObserver: Any?
  
  init(
    eventKitManager: EventKitManager = .shared,
    appCoordinator: AppCoordinator,
    appSettings: AppSettings,
    calendarService: CalendarService?
  ) {
    self.eventKitManager = eventKitManager
    self.appCoordinator = appCoordinator
    self.appSettings = appSettings
    self.calendarService = calendarService
    
    // MARK: Initial App States Check
    checkAppStates()
    
    // MARK: EKEventStoreChanged Observer
    self.eventStoreChangedObserver = NotificationCenter.default.addObserver(
      forName: .EKEventStoreChanged,
      object: eventKitManager.eventStore,
      queue: .main,
      using: { [weak self] _ in
        guard let self else {
          print("[ContentViewModel][KEventStoreChanged Observer] self weak reference point to nil")
          return
        }
        self.checkAppStates()
        print("[ContentViewModel][KEventStoreChanged Observer] was finished")
      }
    )
  }
  
  deinit {
    if let eventStoreChangedObserver {
      NotificationCenter.default.removeObserver(eventStoreChangedObserver)
    }
  }
  
  func checkAppStates() {
    calendarService?.onCalendarsChangedAction()
    checkAuthStatus()
    checkNilCalendar()
  }
  
  private func checkAuthStatus() {
    print("[AppSettings][checkAuthStatus] was called")
    if appSettings.synchronizeCalendar && eventKitManager.authrorizationStatus != .fullAccess {
      appCoordinator.selectedAlert = .noAccessToCalendar
      print("[AppSettings][checkAuthStatus] was completed successful")
    }
  }
  
  private func checkNilCalendar() {
    print("[AppSettings][checkNilCalendar] was called")
    
    let synchronizeCalendar = appSettings.synchronizeCalendar
    let authrorizationStatus = eventKitManager.authrorizationStatus
    let selectedCalendar = appSettings.selectedCalendar
    
    print(
      """
      synchronizeCalendar = \(synchronizeCalendar)
      authStatus = \(authrorizationStatus)
      selectedCalendar = \(selectedCalendar?.title ?? "NONE")
      """
    )
    
    if synchronizeCalendar && authrorizationStatus == .fullAccess && selectedCalendar == nil {
      appCoordinator.selectedAlert = .nilCalendarSelected
      print("[AppSettings][checkNilCalendar] was completed successful")
    }
  }
}
