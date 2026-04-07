//
//  SettingsViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import Foundation
import UIKit


@Observable
final class SettingsManager {
  static let shared = SettingsManager()
  
  private let local = UserDefaults.standard
  
  private let store = NSUbiquitousKeyValueStore.default
  private var saveTask: Task<Void, Never>?
  private var isUpdatingFromCloud = false
  
  // MARK: - Init
  
  private init() {
    // Settings initializing from UserDefaults
    self._synchronizeCalendar = local.bool(forKey: SettingKey.synchronizeCalendar.rawValue)
    self._selectedCalendar = {
      guard let data = local.data(forKey: SettingKey.selectedCalendar.rawValue) else {
        print("No data found in UserDefaults for 'selected_calendar' key")
        return nil
      }
      let decoder = JSONDecoder()
      do {
        return try decoder.decode(CalendarItem.self, from: data)
      } catch {
        print("Decoding error: \(error.localizedDescription)")
        return nil
      }
    }()
    
    // Первоначальная загрузка данных из KVS
    loadFromCloud()
    
    // DEBUG
    NSLog("~\(UIDevice.current.name) init -> loadFromCloud")
    
    // Наблюдатель за изменениями KVS
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(cloudDataChanged),
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: store
    )
  }
  
  // MARK: - Properties
  
  var sessionTitle: String = "Selenite" {
    didSet { scheduleCloudSync() }
  }
  
  var sessionDuration: Int = 25 {
    didSet { scheduleCloudSync() }
  }
  
  var sessionCount: Int = 4 {
    didSet { scheduleCloudSync() }
  }
  
  var sessionAutostart: Bool = false {
    didSet { scheduleCloudSync() }
  }
  
  var areBreaksDisabled: Bool = false {
    didSet { scheduleCloudSync() }
  }
  
  var shortBreakDuration: Int = 5 {
    didSet { scheduleCloudSync() }
  }
  
  var longBreakDuration: Int = 30 {
    didSet { scheduleCloudSync() }
  }
  
  var breakAutostart: Bool = false {
    didSet { scheduleCloudSync() }
  }
  
  // EventKit settings
  var synchronizeCalendar: Bool {
    didSet {
      local.set(synchronizeCalendar, forKey: SettingKey.synchronizeCalendar.rawValue)
    }
  }
  
  var selectedCalendar: CalendarItem? {
    didSet {
      print("[AppSettings][selectedCalendar] didSet was called \(Date())")
      guard oldValue != selectedCalendar else {
        print("[AppSettings][selectedCalendar] selected calendar has not changed. Exiting didSet closure")
        return
      }
      let encoder = JSONEncoder()
      if let data = try? encoder.encode(selectedCalendar) {
        local.set(data, forKey: SettingKey.selectedCalendar.rawValue)
      } else {
        local.removeObject(forKey: SettingKey.selectedCalendar.rawValue)
      }
    }
  }
  
  enum SettingKey: String {
    case synchronizeCalendar = "synchronize_calendar"
    case selectedCalendar = "selected_calendar"
  }
  
  // MARK: - Duration Validation
  
  private let durationLeftBoundary: Int = 1
  private let durationRightBoundary: Int = 120
  private var durationRange: ClosedRange<Int> {
    durationLeftBoundary...durationRightBoundary
  }
  
  func validation(of duration: Int) -> Int {
    switch duration {
    case ...(durationLeftBoundary - 1): return durationLeftBoundary
    case durationRange: return duration
    default: return durationRightBoundary
    }
  }
  
  
  // MARK: - KVS Logic
  
  private func scheduleCloudSync() {
    guard !isUpdatingFromCloud else { return }
    
    saveTask?.cancel()
    saveTask = Task {
      try? await Task.sleep(for: .seconds(2))
      
      if !Task.isCancelled {
        await MainActor.run {
          performCloudSave()
        }
      }
    }
  }
  
  @MainActor
  private func performCloudSave() {
    saveToCloud(value: sessionTitle, key: Keys.sessionTitle)
    saveToCloud(value: sessionDuration, key: Keys.sessionDuration)
    saveToCloud(value: sessionCount, key: Keys.sessionCount)
    saveToCloud(value: sessionAutostart, key: Keys.sessionAutostart)
    
    saveToCloud(value: areBreaksDisabled, key: Keys.areBreaksDisabled)
    saveToCloud(value: shortBreakDuration, key: Keys.shortBreakDuration)
    saveToCloud(value: longBreakDuration, key: Keys.longBreakDuration)
    saveToCloud(value: breakAutostart, key: Keys.breakAutostart)
    
    store.synchronize()
    NSLog("~\(UIDevice.current.name) Cloud Sync Completed")
  }
  
  
  private func loadFromCloud() {
    isUpdatingFromCloud = true
    defer { isUpdatingFromCloud = false }
    
    if let value = store.string(forKey: Keys.sessionTitle) { sessionTitle = value }
    
    if let value = getInt(for: Keys.sessionDuration) { sessionDuration = value }
    if let value = getInt(for: Keys.sessionCount) { sessionCount = value }
    
    if store.object(forKey: Keys.sessionAutostart) != nil {
      sessionAutostart = store.bool(forKey: Keys.sessionAutostart)
    }
    if store.object(forKey: Keys.areBreaksDisabled) != nil {
      areBreaksDisabled = store.bool(forKey: Keys.areBreaksDisabled)
    }
    
    if let value = getInt(for: Keys.shortBreakDuration) { shortBreakDuration = value }
    if let value = getInt(for: Keys.longBreakDuration) { longBreakDuration = value }
    
    if store.object(forKey: Keys.breakAutostart) != nil {
      breakAutostart = store.bool(forKey: Keys.breakAutostart)
    }
    
    NSLog("~\(UIDevice.current.name) loadFromCloud finished")
  }
  
  private func saveToCloud(value: Any, key: String) {
    if let intValue = value as? Int, store.longLong(forKey: key) != Int64(intValue) {
      store.set(Int64(intValue), forKey: key)
    } else if let boolValue = value as? Bool, store.bool(forKey: key) != boolValue {
      store.set(boolValue, forKey: key)
    } else if let stringValue = value as? String, store.string(forKey: key) != stringValue {
      store.set(stringValue, forKey: key)
    }
    // DEBUG
    NSLog("~\(UIDevice.current.name) saveToCloud \(value)")
  }
  
  private func getInt(for key: String) -> Int? {
    if store.object(forKey: key) != nil {
      return Int(store.longLong(forKey: key))
    }
    return nil
  }
  
  @objc private func cloudDataChanged(notification: Notification) {
    DispatchQueue.main.async { [weak self] in
      self?.loadFromCloud()
      // DEBUG
      NSLog("~\(UIDevice.current.name) cloudDataChanged[Notification] -> loadFromCloud")
    }
  }
  
  private enum Keys {
    static let sessionTitle = "sessionTitle"
    static let sessionDuration = "sessionDuration"
    static let sessionCount = "sessionCount"
    static let sessionAutostart = "sessionAutostart"
    static let areBreaksDisabled = "areBreaksDisabled"
    static let shortBreakDuration = "shortBreakDuration"
    static let longBreakDuration = "longBreakDuration"
    static let breakAutostart = "breakAutostart"
  }
}


