//
//  AppCoordinator.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 15.04.2026.
//

import Foundation

@Observable
final class AppCoordinator {
  var selectedTab: Tab = .timer
  
  enum Tab {
    case statistics
    case timer
    case settings
  }
}
