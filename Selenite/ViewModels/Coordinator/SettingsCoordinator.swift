//
//  SettingsCoordinator.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 19.04.2026.
//

import Foundation

enum SettingsAlertType {
  case deleteAll
  
  var title: String {
    switch self {
    case .deleteAll: "Очистить историю сессий"
    }
  }
  
  var message: String {
    switch self {
    case .deleteAll: "Все записанные сессии будут удалены безвозвратно"
    }
  }
}

@Observable
final class SettingsCoordinator {
  var selectedAlert: SettingsAlertType?
}
