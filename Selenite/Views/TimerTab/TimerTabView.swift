//
//  TimerView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct TimerTabView: View {
  @Environment(\.modelContext) private var modelContext: ModelContext
  @Environment(TimerManager.self) private var timerManager
  
  var body: some View {
    VStack(spacing: 5) {
      Text(timerManager.displayCount())
        .id(timerManager.pulse)
        .font(.system(size: 82))
        .fontWeight(.bold)
      
      Button(action: { timerManager.playButtonAction(modelContext: modelContext) }) {
        Image(systemName: "play")
      }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.large)
    }
  }
}

#Preview {
  TimerTabView()
    .modelContainer(for: [Session.self, SessionInterval.self])
    .environment(TimerManager())
    .tint(.purple.mix(with: .red, by: 0.6))
}
