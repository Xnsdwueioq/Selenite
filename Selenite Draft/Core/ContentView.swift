//
//  TabsView.swift
//  Selenite Draft
//
//  Created by Eyhciurmrn Zmpodackrl on 15.04.2026.
//

import SwiftUI

struct TabsView: View {
  @Environment(AppCoordinator.self) private var appCoordinator
  
  var body: some View {
    @Bindable var appCoordinator = appCoordinator
    
    // Tabs
    TabView(selection: $appCoordinator.selectedTab) {
      
    }
  }
}

#Preview {
  TabsView()
}
