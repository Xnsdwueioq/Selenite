//
//  NotificationExplainingView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import SwiftUI

struct NotificationExplainingView: View {
  let notNow: () -> Void
  let submit: () -> Void
  
  var body: some View {
    VStack {
      ContentUnavailableView(
        "Доступ к уведомлениям",
        systemImage: "bell",
        description: Text("Разрешите доступ к уведомлениям со звуком, для того чтобы получать оповещения о состоянии таймера")
      )
      HStack {
        buttons
      }
    }
  }
  
  @ViewBuilder
  private var buttons: some View {
    if #available(iOS 26.0, *) {
      Group {
        Button(role: .close, action: notNow) {
          Text("Не сейчас")
        }
        .buttonStyle(.glass)
        Button(role: .confirm, action: submit) {
          Text("Разрешить")
        }
        .buttonStyle(.glassProminent)
      }
    } else {
      Group {
        Button("Не сейчас", action: notNow)
          .buttonStyle(.bordered)
        Button("Разрешить", action: submit)
          .buttonStyle(.borderedProminent)
      }
    }
  }
}

#Preview {
  NotificationExplainingView(notNow: { }, submit: { })
}
