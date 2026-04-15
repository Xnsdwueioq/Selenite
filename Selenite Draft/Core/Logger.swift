//
//  Logger.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 15.04.2026.
//

import OSLog

extension Logger {
  private static var subsystem = Bundle.main.bundleIdentifier!
  
  static let ui = Logger(subsystem: subsystem, category: "UI")
  static let period = Logger(subsystem: subsystem, category: "Period")
  static let database = Logger(subsystem: subsystem, category: "Database")
  static let timer = Logger(subsystem: subsystem, category: "TimerLogic")
}
