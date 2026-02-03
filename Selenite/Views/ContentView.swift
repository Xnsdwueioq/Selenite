//
//  ContentView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData


enum AppTab: Identifiable {
  case statistics
  case timer
  case settings
  
  var id: Self { return self }
  
  var systemImage: String {
    switch self {
    case .statistics: return "chart.bar.xaxis"
    case .timer: return "play"
    case .settings: return "gear"
    }
  }
}

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var timerManager = TimerManager(settingsManager: .shared)
  @State private var selectedTab = AppTab.timer
  
  var body: some View {
    TabView(selection: $selectedTab) {
      // MARK: Statistic Tab
      Tab(value: AppTab.statistics, content: {
        StatisticsTabView()
      }, label: {
        Image(systemName: AppTab.statistics.systemImage)
      })
      
      // MARK: Timer Tab
      Tab(value: AppTab.timer, content: {
        TimerTabView()
      }, label: {
        Image(systemName: AppTab.timer.systemImage)
      })
      
      // MARK: Settings Tab
      Tab(value: AppTab.settings, content: {
        SettingsTabView()
      }, label: {
        Image(systemName: AppTab.settings.systemImage)
      })
    }
    .environment(timerManager)
    .onAppear {
      timerManager.modelContext = modelContext
    }
  }
}

#Preview {
  let container: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try! ModelContainer(for: Period.self, PeriodInterval.self, configurations: config)
  }()
  
  let previewManager = TimerManager(
    settingsManager: .shared,
    modelContext: container.mainContext
  )
  
  ContentView()
    .modelContainer(container)
    .environment(previewManager)
    .tint(.purpleBrand)
}
