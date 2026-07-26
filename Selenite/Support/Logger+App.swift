//
//  Logger+App.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import OSLog

extension Logger {
  private static let subsystem = Bundle.main.bundleIdentifier!
  
  static let timerEngine = Logger(subsystem: subsystem, category: "timerEngine")
  
}
