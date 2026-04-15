//
//  Selenite_DraftApp.swift
//  Selenite Draft
//
//  Created by Eyhciurmrn Zmpodackrl on 15.04.2026.
//

import SwiftUI

@main
struct Selenite_DraftApp: App {
  @State private var appCoordinator = AppCoordinator()
  
  var body: some Scene {
    WindowGroup {
      TabsView()
        .environment(appCoordinator)
    }
  }
}
