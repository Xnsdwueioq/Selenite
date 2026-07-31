//
//  NotificationDeliveryIssue+Priority.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/29/26.
//

nonisolated extension NotificationDeliveryIssue {
  static let bySeverity: [Self] = [.scheduledDelivery, .soundDisabled, .alertsDisabled, .lockScreenDisabled, .notificationCenterDisabled]
  
  static func mostSevere(in issues: Set<Self>) -> Self? {
    bySeverity.first { issues.contains($0) }
  }
}
