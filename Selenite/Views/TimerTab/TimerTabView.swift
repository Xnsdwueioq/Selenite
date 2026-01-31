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
    let _ = timerManager.pulse
    VStack(spacing: 5) {
      Text(timerManager.remainingTime())
        .font(.system(size: 82))
        .fontWeight(.medium)
      
      Button(action: { timerManager.playButtonAction(modelContext: modelContext) }) {
        Image(systemName: timerManager.playButtonSystemImage())
          .animation(.none, value: timerManager.state)
        
      }
      .buttonStyle(.glassProminent)
      .buttonBorderShape(.circle)
      .controlSize(.extraLarge)
    }
  }
}

#Preview {
  TimerTabView()
    .modelContainer(for: [Session.self, SessionInterval.self])
    .environment(TimerManager(settingsManager: SettingsManager.shared))
    .tint(.purple.mix(with: .red, by: 0.6))
}
