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
        defaultValue: "Уведомления придут, но не будут показываться баннером"
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
    case .notificationCenterDisabled:
      return String(
        localized: "notification.warning.notificationCenterDisabled",
        defaultValue: "Уведомления не появятся в центре уведомлений"
      )
    }
  }
  
  static var noChannelsWarningText: String {
    return String(
      localized: "notification.warning.noChannels",
      defaultValue: "Уведомления не появятся на экране, звук тоже выключен"
    )
  }

  static var soundOnlyWarningText: String {
    return String(
      localized: "notification.warning.soundOnly",
      defaultValue: "Уведомления не появятся на экране, останется только звук"
    )
  }

  static var notificationCenterOnlyWarningText: String {
    return String(
      localized: "notification.warning.notificationCenterOnly",
      defaultValue: "Уведомления придут только в центр уведомлений"
    )
  }

  static func warningText(for issues: Set<Self>) -> String? {
    // ScheduledDelivery
    if issues.contains(.scheduledDelivery) {
      return Self.scheduledDelivery.warningText
    }

    // NoChannels
    let noChannels: Set<Self> = [.soundDisabled, .alertsDisabled, .lockScreenDisabled, .notificationCenterDisabled]

    if issues.isSuperset(of: noChannels) {
      return Self.noChannelsWarningText
    }

    // SoundOnly
    let soundOnly: Set<Self> = [.notificationCenterDisabled, .alertsDisabled, .lockScreenDisabled]

    if issues.isSuperset(of: soundOnly) {
      return Self.soundOnlyWarningText
    }

    // NotificationCenterOnly
    let notificationCenterOnly: Set<Self> = [.soundDisabled, .alertsDisabled, .lockScreenDisabled]

    if issues.isSuperset(of: notificationCenterOnly) {
      return Self.notificationCenterOnlyWarningText
    }

    // [Most severe]
    return mostSevere(in: issues)?.warningText
  }
}
