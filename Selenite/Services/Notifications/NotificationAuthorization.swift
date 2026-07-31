//
//  NotificationAuthorization.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import UserNotifications
import OSLog

nonisolated enum NotificationAuthorizationStatus {
  case notDetermined, authorized, denied
}

nonisolated enum NotificationDeliveryIssue: CaseIterable {
  case scheduledDelivery
  case alertsDisabled
  case soundDisabled
  case lockScreenDisabled
  case notificationCenterDisabled
}

nonisolated struct NotificationStatus: Equatable {
  var authorization: NotificationAuthorizationStatus
  var issues: Set<NotificationDeliveryIssue> = []
}

nonisolated struct NotificationSettingsSnapshot {
  var authorizationStatus: UNAuthorizationStatus
  var alertSetting: UNNotificationSetting
  var soundSetting: UNNotificationSetting
  var lockScreenSetting: UNNotificationSetting
  var scheduledDeliverySetting: UNNotificationSetting
  var notificationCenterSetting: UNNotificationSetting
}

nonisolated enum NotificationAuthorization {
  static func requestAuthorization() async -> NotificationStatus {
    do {
      try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    } catch {
      Logger.notifications.error("Permission retrieval error: \(error.localizedDescription)")
    }

    return await current()
  }

  static func current() async -> NotificationStatus {
    status(for: await settings())
  }

  static func status(for settings: NotificationSettingsSnapshot) -> NotificationStatus {
    switch settings.authorizationStatus {
    case .notDetermined:
      NotificationStatus(authorization: .notDetermined)
    case .denied:
      NotificationStatus(authorization: .denied)
    case .authorized, .provisional, .ephemeral:
      NotificationStatus(authorization: .authorized, issues: issues(for: settings))
    @unknown default:
      NotificationStatus(authorization: .denied)
    }
  }

  private static func issues(for settings: NotificationSettingsSnapshot) -> Set<NotificationDeliveryIssue> {
    var issues: Set<NotificationDeliveryIssue> = []
    if settings.scheduledDeliverySetting == .enabled { issues.insert(.scheduledDelivery) }
    if settings.alertSetting == .disabled { issues.insert(.alertsDisabled) }
    if settings.soundSetting == .disabled { issues.insert(.soundDisabled) }
    if settings.lockScreenSetting == .disabled { issues.insert(.lockScreenDisabled) }
    if settings.notificationCenterSetting == .disabled { issues.insert(.notificationCenterDisabled) }
    
    return issues
  }

  private static func settings() async -> NotificationSettingsSnapshot {
    let settings = await UNUserNotificationCenter.current().notificationSettings()

    return NotificationSettingsSnapshot(
      authorizationStatus: settings.authorizationStatus,
      alertSetting: settings.alertSetting,
      soundSetting: settings.soundSetting,
      lockScreenSetting: settings.lockScreenSetting,
      scheduledDeliverySetting: settings.scheduledDeliverySetting,
      notificationCenterSetting: settings.notificationCenterSetting
    )
  }
}
