//
//  TimerView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct TimerTabView: View {
  @Environment(TimerManager.self) private var timerManager
  @State private var title = "Selenite"
  
  var body: some View {
    let _ = timerManager.pulse
    NavigationStack {
      VStack(spacing: 5) {
        TextField("Название", text: $title)
          .textFieldStyle(.roundedBorder)
          .padding(.horizontal, 50)
          .font(.title2)
          .multilineTextAlignment(.center)
        // TIMER
        Text(timerManager.remainingTime())
          .font(.system(size: 82))
          .fontWeight(.medium)
        
        HStack {
          // PREV BUTTON
          Button(action: {
            timerManager.previousButtonAction()
          }) {
            Image(systemName: "chevron.left")
          }
   
          // PLAY/PAUSE BUTTON
          Button(action: {
            timerManager.playButtonAction()
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
      .toolbar {
        ToolbarItem(placement: .topBarTrailing, content: {
          // RESTART BUTTON
          Button(action: {
            timerManager.resetButtonAction()
          }) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
          }
          .buttonStyle(.glass)
          .buttonBorderShape(.circle)
        })
        .sharedBackgroundVisibility(.hidden)
      }
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
  
  TimerTabView()
    .modelContainer(container)
    .environment(previewManager)
    .tint(.purpleBrand)
}
