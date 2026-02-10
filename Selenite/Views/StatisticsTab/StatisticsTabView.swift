//
//  StatisticsTabView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

enum AppRoute: Hashable {
  case sessionList
  case sessionEdit(session: Period)
}

struct StatisticsTabView: View {
  var body: some View {
    NavigationStack {
      Form {
        NavigationLink("История сессий", value: AppRoute.sessionList)
      }
      .navigationDestination(for: AppRoute.self) { route in
        switch route {
        case .sessionList:
          SessionListView()
        case .sessionEdit(let session):
          SessionEditView(session: session)
        }
      }
    }
  }
}

#Preview {
  StatisticsTabView()
    .modelContainer(for: [Period.self, PeriodInterval.self])
    .environment(TimerManager(settingsManager: SettingsManager.shared))
    .tint(.purple.mix(with: .red, by: 0.6))
}
