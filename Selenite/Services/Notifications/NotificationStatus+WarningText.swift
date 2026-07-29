//
//  NotificationStatus+WarningText.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/29/26.
//

import Foundation

extension NotificationStatus {
  var warningText: String? {
    switch authorization {
    case .authorized:
      NotificationDeliveryIssue.mostSevere(in: issues)?.warningText
      
    case .denied: String(
      localized: "notification.warning.denied",
      defaultValue: "Уведомления выключены, таймер не сообщит об окончании"
    )
      
    case .notDetermined: nil
    }
  }
}
