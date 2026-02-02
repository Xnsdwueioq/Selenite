//
//  ContentView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var timerManager = TimerManager(settingsManager: .shared)
  
  var body: some View {
    TabView {
      // MARK: Statistics Tab
      Tab(content: {
        StatisticsTabView()
      }) {
        Image(systemName: "chart.bar.xaxis")
      }
      
      // MARK: Timer Tab
      Tab(content: {
        TimerTabView()
          .environment(timerManager)
      }) {
        Image(systemName: "play")
      }
      
      // MARK: Settings Tab
      Tab(content: {
        SettingsTabView()
      }) {
        Image(systemName: "gear")
      }
    }
    .onAppear {
      timerManager.modelContext = modelContext
    }
    .tint(.purple.mix(with: .red, by: 0.6))
  }
}

#Preview {
  // 1. Готовим зависимости
      let container: ModelContainer = {
          let config = ModelConfiguration(isStoredInMemoryOnly: true)
          return try! ModelContainer(for: Period.self, PeriodInterval.self, configurations: config)
      }()
      
      let previewManager = TimerManager(
          settingsManager: .shared,
          modelContext: container.mainContext
      )
      
      // 2. Просто возвращаем View (без слова return)
      ContentView()
          .modelContainer(container)
          .environment(previewManager)
}
