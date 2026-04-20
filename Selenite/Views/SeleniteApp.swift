//
//  SeleniteApp.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 28.01.2026.
//

import SwiftUI
import SwiftData

@main
struct SeleniteApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .tint(.purpleBrand)
    }
    .modelContainer(for: [Period.self, PeriodInterval.self])
  }
}

#Preview {
  ContentView()
    .modelContainer(for: [Period.self, PeriodInterval.self])
}
