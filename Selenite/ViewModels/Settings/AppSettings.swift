//
//  AppSettings.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 30.01.2026.
//

import Foundation
import UIKit
import EventKit

@Observable
final class AppSettings {
  private let settingsManager: SettingsManager
  
  init(settingsManager: SettingsManager = .shared) {
    self.settingsManager = settingsManager
  }
  
  // MARK: - KVS Settings
  
  var sessionTitle: String {
    get { settingsManager.sessionTitle }
    set { settingsManager.sessionTitle = newValue }
  }
  
  var sessionDuration: Double {
    get { Double(settingsManager.sessionDuration) }
    set { settingsManager.sessionDuration = Int(newValue) }
  }
  
  var sessionCount: Double {
    get { Double(settingsManager.sessionCount) }
    set { settingsManager.sessionCount = Int(newValue) }
  }
  
  var sessionAutostart: Bool {
    get { settingsManager.sessionAutostart }
    set { settingsManager.sessionAutostart = newValue }
  }
  
  var areBreaksDisabled: Bool {
    get { settingsManager.areBreaksDisabled }
    set { settingsManager.areBreaksDisabled = newValue }
  }
  
  var shortBreakDuration: Double {
    get { Double(settingsManager.shortBreakDuration) }
    set { settingsManager.shortBreakDuration = Int(newValue) }
  }
  
  var longBreakDuration: Double {
    get { Double(settingsManager.longBreakDuration) }
    set { settingsManager.longBreakDuration = Int(newValue) }
  }
  
  var breakAutostart: Bool {
    get { settingsManager.breakAutostart }
    set { settingsManager.breakAutostart = newValue }
  }
  
  // MARK: - Local Settings
  
  var synchronizeCalendar: Bool {
    get { settingsManager.synchronizeCalendar }
    set { settingsManager.synchronizeCalendar = newValue }
  }
  
  var selectedCalendar: CalendarItem? {
    get { settingsManager.selectedCalendar }
    set { settingsManager.selectedCalendar = newValue }
  }
  
  // MARK: - Drive
  
  func checkAuthStatus(eventKitManager: EventKitManager = .shared, appCoordinator: AppCoordinator) {
    print("[AppSettings][checkAuthStatus] was called")
    if synchronizeCalendar && eventKitManager.authrorizationStatus != .fullAccess {
      appCoordinator.selectedAlert = .noAccessToCalendar
    }
  }
  
  func checkNilCalendar(eventKitManager: EventKitManager = .shared, appCoordinator: AppCoordinator) {
    print("[AppSettings][checkNilCalendar] was called")
    if synchronizeCalendar && eventKitManager.authrorizationStatus == .fullAccess && selectedCalendar == nil {
      appCoordinator.selectedAlert = .nilCalendarSelected
    }
  }
}
