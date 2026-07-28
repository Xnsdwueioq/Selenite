//
//  NotificationAuthorization.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import UserNotifications
import OSLog

nonisolated enum NotificationStatusResponse {
  case notDetermined
  case authorizedWithSound
  case authorizedWithoutSound
  case denied
}

nonisolated enum NotificationAuthorization {
  static func requestAuthorization() async -> NotificationStatusResponse {
    do {
      try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
      
    } catch {
      Logger.notifications.error("Permission retrieval error: \(error.localizedDescription)")
    }
    
    let (authorizationStatus, soundSetting) = await settings()
    return status(authorizationStatus: authorizationStatus, soundSetting: soundSetting)
  }
  
  static func settings() async -> (UNAuthorizationStatus, UNNotificationSetting) {
    let settings = await UNUserNotificationCenter.current().notificationSettings()

    let soundSetting = settings.soundSetting
    let authorizationStatus = settings.authorizationStatus
    
    return (authorizationStatus, soundSetting)
  }
  
  static func status(
    authorizationStatus: UNAuthorizationStatus,
    soundSetting: UNNotificationSetting
  ) -> NotificationStatusResponse {
    switch authorizationStatus {
    case .notDetermined: return .notDetermined
    case .denied: return .denied
    case .authorized:
      if soundSetting == .enabled {
        return .authorizedWithSound
      } else {
        return .authorizedWithoutSound
      }
    case .provisional, .ephemeral: return .authorizedWithoutSound
    @unknown default: return .denied
    }
  }
}
