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
      // RESTART BUTTON
      Button(action: {
        timerManager.resetButtonAction(modelContext: modelContext)
      }) {
        Image(systemName: "arrow.counterclockwise.circle.fill")
      }
      .buttonStyle(.glassProminent)
      .buttonBorderShape(.circle)
      .controlSize(.extraLarge)
      
      // TIMER
      Text(timerManager.remainingTime())
        .font(.system(size: 82))
        .fontWeight(.medium)
      
      HStack {
        // PREV BUTTON
        Button(action: {
          timerManager.previousButtonAction(modelContext: modelContext)
        }) {
          Image(systemName: "chevron.left")
        }
        
        // PLAY/PAUSE BUTTON
        Button(action: {
          timerManager.playButtonAction(modelContext: modelContext)
        }) {
          Image(systemName: timerManager.playButtonSystemImage())
            .animation(.none, value: timerManager.periodState)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .controlSize(.extraLarge)
        
        // NEXT BUTTON
        Button(action: {
          timerManager.nextButtonAction()
        }) {
          Image(systemName: "chevron.right")
        }
      }
      
      // INDICATORS
      SessionProgressView(total: timerManager.getSessionsTotalNumber(), current: timerManager.getCurrentSessionNumber(), sessionIndicator: timerManager.getCurrentSessionIndicator())
    }
  }
}


#Preview {
  TimerTabView()
    .modelContainer(for: [Period.self, PeriodInterval.self])
    .environment(TimerManager(settingsManager: SettingsManager.shared))
    .tint(.purple.mix(with: .red, by: 0.6))
}
