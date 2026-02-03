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
  
  private let store = NSUbiquitousKeyValueStore.default
  
  var sessionTitle: String = "Selenite" {
    didSet {
      saveToCloud(value: sessionTitle, key: Keys.sessionTitle)
    }
  }
  
  var sessionDuration: Int = 25 {
    didSet {
      saveToCloud(value: sessionDuration, key: Keys.sessionDuration)
    }
  }
  var sessionCount: Int = 4 {
    didSet {
      saveToCloud(value: sessionCount, key: Keys.sessionCount)
    }
  }
  var sessionAutostart: Bool = false {
    didSet {
      saveToCloud(value: sessionAutostart, key: Keys.sessionAutostart)
    }
  }
  
  var areBreaksDisabled: Bool = false {
    didSet {
      saveToCloud(value: areBreaksDisabled, key: Keys.areBreaksDisabled)
    }
  }
  var shortBreakDuration: Int = 5 {
    didSet {
      saveToCloud(value: shortBreakDuration, key: Keys.shortBreakDuration)
    }
  }
  var longBreakDuration: Int = 30 {
    didSet {
      saveToCloud(value: longBreakDuration, key: Keys.longBreakDuration)
    }
  }
  var breakAutostart: Bool = false {
    didSet {
      saveToCloud(value: breakAutostart, key: Keys.breakAutostart)
    }
  }
  
  private init() {
    loadFromCloud()
    // DEBUG
    NSLog("~\(UIDevice.current.name) init -> loadFromCloud")
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(cloudDataChanged),
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: store
    )
  }
  
  private func loadFromCloud() {
    if let value = store.string(forKey: Keys.sessionTitle) {
      sessionTitle = value
    }
    
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
    store.synchronize()
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
