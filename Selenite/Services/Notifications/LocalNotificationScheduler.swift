//
//  LocalNotificationScheduler.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/27/26.
//

import FocusCore
import UserNotifications
import OSLog

nonisolated struct LocalNotificationScheduler: NotificationScheduling {
  private static let notificationQuota = 40
  private static let boundaryNotificationPrefix = "boundary."
  private let notificationCenter = UNUserNotificationCenter.current()
  private let now: () -> Date
  
  init(now: @escaping () -> Date) {
    self.now = now
  }
  
  func reschedule(to boundaries: [PhaseBoundary]) async {
    await cancelAll()
    for request in requests(for: boundaries) {
      do {
        try await notificationCenter.add(request)
      } catch {
        Logger.notifications.error("Unable to add the notification with id='\(request.identifier)': \(error.localizedDescription)")
      }
    }
  }
  
  
  func cancelAll() async {
    let requests = await notificationCenter.pendingNotificationRequests()
    let boundaryIdentifiers = ownIdentifiers(from: requests)
    notificationCenter.removePendingNotificationRequests(withIdentifiers: boundaryIdentifiers)
  }
  
  func requests(for boundaries: [PhaseBoundary]) -> [UNNotificationRequest] {
    var requests: [UNNotificationRequest] = []
    for boundary in boundaries.prefix(Self.notificationQuota) {
      guard let request = buildNotificationRequest(with: boundary) else { continue }
      requests.append(request)
    }
    return requests
  }
  
  func ownIdentifiers(from pending: [UNNotificationRequest]) -> [String] {
    let identifiers: [String] = pending.compactMap {
      if $0.identifier.hasPrefix(Self.boundaryNotificationPrefix) {
        return $0.identifier
      }
      return nil
    }
    return identifiers
  }
  
  private func buildNotificationRequest(with boundary: PhaseBoundary) -> UNNotificationRequest? {
    let distanceToBoundary = boundary.completionAt.timeIntervalSince(now())
    guard distanceToBoundary > 0 else {
      Logger.notifications.warning("An attempt to create a notification for a past event")
      return nil
    }
    
    // Identifier
    let identifier = Self.boundaryNotificationPrefix + String(Int(boundary.completionAt.timeIntervalSince1970))
    
    // Content
    let content = UNMutableNotificationContent()
    (content.title, content.body) = NotificationContentBuilder.content(for: boundary)
    content.sound = .default
    
    // Trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: distanceToBoundary, repeats: false)
    
    // Request
    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger
    )
    
    return request
  }
  
}
