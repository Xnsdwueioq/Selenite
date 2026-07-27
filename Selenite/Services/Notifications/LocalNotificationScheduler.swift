//
//  LocalNotificationScheduler.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/27/26.
//

import FocusCore
import UserNotifications

struct LocalNotificationScheduler: NotificationScheduling {
  private static let notificationQuota = 40
  private static let boundaryNotificationPrefix = "boundary."
  private let notificationCenter = UNUserNotificationCenter.current()
  
  func reschedule(to boundaries: [PhaseBoundary]) async {
    for boundary in boundaries {
    }
  }
  
  func cancelAll() async {
    
  }
  
  func requestAuthorization() async {
    do {
      let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
      if granted {
        let settings = await notificationCenter.notificationSettings()
      }
    } catch {
      
    }
  }
}
