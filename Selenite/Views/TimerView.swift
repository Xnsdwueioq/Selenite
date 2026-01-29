//
//  TimerView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct TimerView: View {
  @Environment(\.modelContext) private var modelContext: ModelContext
  @State private var timerManager = TimerManager()
  
  var body: some View {
    VStack {
      Text(timerManager.displayCount())
        .id(timerManager.pulse)
      Button("Button", systemImage: "play") {
        timerManager.playButtonAction(modelContext: modelContext)
      }
    }
    .onChange(of: timerManager.pulse) {
      print(timerManager.activeSession?.sessionDuration as Any)
    }
  }
}

#Preview {
  TimerView()
    .modelContainer(for: [Session.self, SessionInterval.self])
}
