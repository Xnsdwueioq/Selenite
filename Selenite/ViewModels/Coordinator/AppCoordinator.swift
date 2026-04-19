//
//  AppCoordinator.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 18.04.2026.
//

import Foundation
import SwiftUI

enum AppTab: Identifiable {
  case statistics
  case timer
  case settings
  
  var id: Self { return self }
  
  var systemImage: String {
    switch self {
    case .statistics: return "chart.bar.xaxis"
    case .timer: return "play"
    case .settings: return "gear"
    }
  }
}

enum AppAlertType {
  case noAccessToCalendar
  case nilCalendarSelected
  
  var title: String {
    switch self {
    case .noAccessToCalendar: "Нет доступа"
    case .nilCalendarSelected: "Календарь не выбран"
    }
  }
  
  var message: String {
    switch self {
    case .noAccessToCalendar: "Предоставьте полный доступ к календарю в настройках устройства"
    case .nilCalendarSelected: "Выберите новый календарь для возможности синхронизации с Apple Calendar"
    }
  }
}

@Observable
final class AppCoordinator {
  var selectedTab: AppTab = .timer
  var selectedAlert: AppAlertType?
  
  var statisticsCoordinator = StatisticsCoordinator()
  var settingsCoordindator = SettingsCoordinator()
  
  func openSystemSettings() async {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      await UIApplication.shared.open(url)
    }
  }
  
  func openCalendarSelectionSheet() {
    selectedTab = .settings
    settingsCoordindator.isCalendarSelected = true
  }
}


