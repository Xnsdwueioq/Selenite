//
//  NotificationStatus+WarningText.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/29/26.
//

import Foundation

nonisolated extension NotificationStatus {
  var warningText: String? {
    switch authorization {
    case .authorized:
      NotificationDeliveryIssue.warningText(for: self.issues)
      
    case .denied: String(
      localized: "notification.warning.denied",
      defaultValue: "Уведомления выключены, таймер не сообщит об окончании"
    )
      
    case .notDetermined: nil
    }
  }
}
