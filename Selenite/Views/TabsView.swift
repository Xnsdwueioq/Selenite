//
//  TabsView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 18.04.2026.
//

import SwiftUI

struct TabsView: View {
  @Environment(AppSettings.self) private var appSettings
  @Environment(AppCoordinator.self) private var appCoordinator
  
  var body: some View {
    @Bindable var appCoordinator = appCoordinator
    
    TabView(selection: $appCoordinator.selectedTab) {
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
        SettingsTabView(appSettings: appSettings, appCoordinator: appCoordinator)
      }, label: {
        Image(systemName: AppTab.settings.systemImage)
      })
    }
  }
}

#Preview {
  TabsView()
}
