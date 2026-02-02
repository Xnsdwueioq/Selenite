//
//  ContentView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @State private var timerManager = TimerManager(settingsManager: SettingsManager.shared)
  
  var body: some View {
    TabView {
      Tab(content: { StatisticsTabView() }) {
        Image(systemName: "chart.bar.xaxis")
      }
      Tab(content: { TimerTabView() }) {
        Image(systemName: "play")
      }
      Tab(content: { SettingsTabView() }) {
        Image(systemName: "gear")
      }
    }
    .tint(.purple.mix(with: .red, by: 0.6))
    .environment(timerManager)
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Period.self, PeriodInterval.self, configurations: config)
  
  return ContentView()
    .modelContainer(container)
    .environment(TimerManager(settingsManager: SettingsManager.shared))
}
