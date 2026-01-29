//
//  ContentView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @State private var timerManager = TimerManager()
  
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
  ContentView()
    .modelContainer(for: [Session.self, SessionInterval.self])
}
