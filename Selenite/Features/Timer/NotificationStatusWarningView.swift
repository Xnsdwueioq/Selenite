//
//  NotificationStatusWarningView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/29/26.
//

import SwiftUI

struct NotificationStatusWarningView: View {
  @Environment(\.openURL) private var openURL
  let status: NotificationStatus?
  
  private var url: URL? {
    URL(string: UIApplication.openNotificationSettingsURLString)
  }
  
  private func openSettings() {
    if let url {
      openURL(url)
    }
  }
  
  var body: some View {
    if let status, let text = status.warningText {
      WarningLinkButton(
        text: text,
        action: openSettings
      )
    }
  }
}

// TODO: MOVE TO DESIGN SYSTEM
struct WarningLinkButton: View {
  let text: String
  let action: () -> Void
  
  var body: some View {
    Button(
      text,
      systemImage: "arrow.up.right.circle.fill",
      action: action
    )
    .font(.caption)
    .tint(.orange)
  }
}

#Preview("Warning: Уведомление без звука") {
  NotificationStatusWarningView(
    status: NotificationStatus(authorization: .authorized, issues: [.soundDisabled])
  )
}

#Preview("Warning: Уведомления запрещены") {
  NotificationStatusWarningView(status: NotificationStatus(authorization: .denied))
}
