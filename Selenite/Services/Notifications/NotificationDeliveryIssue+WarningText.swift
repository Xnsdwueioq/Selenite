//
//  NotificationDeliveryIssue+WarningText.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/29/26.
//

import Foundation

nonisolated extension NotificationDeliveryIssue {
  var warningText: String {
    switch self {
    case .alertsDisabled:
      return String(
        localized: "notification.warning.alertsDisabled",
        defaultValue: "Уведомления придут, но не появятся на экране"
      )
    case .lockScreenDisabled:
      return String(
        localized: "notification.warning.lockScreenDisabled",
        defaultValue: "Уведомления не появятся на заблокированном экране"
      )
    case .scheduledDelivery:
      return String(
        localized: "notification.warning.scheduledDelivery",
        defaultValue: "Уведомления придут не сразу, а сводкой по расписанию"
      )
    case .soundDisabled:
      return String(
        localized: "notification.warning.soundDisabled",
        defaultValue: "Уведомления придут, но без звука"
      )
    }
  }
}
