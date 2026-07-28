//
//  Logger+App.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import OSLog

nonisolated extension Logger {
  private static let subsystem = AppIdentifiers.bundle
  
  static let timerEngine = Logger(subsystem: subsystem, category: "timerEngine")
  static let effects = Logger(subsystem: subsystem, category: "effects")
  static let sharedSnapshotStore = Logger(subsystem: subsystem, category: "sharedSnapshotStore")
  static let notifications = Logger(subsystem: subsystem, category: "notifications")
}
