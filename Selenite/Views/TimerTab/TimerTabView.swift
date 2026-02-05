//
//  TimerTabView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct TimerTabView: View {
  @Environment(TimerManager.self) private var timerManager
  @Environment(SettingsViewModel.self) private var settingsVM
  
  @State private var viewModel = TimerTabViewModel(settingsManager: .shared)
  
  var body: some View {
    let _ = timerManager.pulse
    NavigationStack {
      VStack(spacing: 5) {
        // TEXTFIELD
        TextField(
          "Название",
          text: Binding(
            get: {
              timerManager.getTitle()
            },
            set: { newValue in
              settingsVM.sessionTitle = newValue
            }
          ),
          prompt:
            Text("Selenite")
        )
        .font(.title)
        .padding(.horizontal, 50)
        .autocorrectionDisabled()
        .multilineTextAlignment(.center)
        .disabled(timerManager.getDisableCondition())
        
        // TIMER
        Text(timerManager.remainingTime())
          .font(.system(size: 82))
          .fontWeight(.medium)
        
        VStack(spacing: 20) {
          // INDICATORS
          SessionProgressView(total: timerManager.getSessionsTotalNumber(), current: timerManager.getCurrentSessionNumber(), sessionIndicator: timerManager.getCurrentSessionIndicator())
            .animation(.easeInOut(duration: 0.2), value: timerManager.currentSessionIndicator)
          
          // PLAY CONTROLS
          HStack(spacing: 20) {
            // PREV BUTTON
            Button(action: {
              timerManager.previousButtonAction()
            }) {
              Image(systemName: "chevron.left")
                .foregroundStyle(.black)
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
                .foregroundStyle(.black)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .contentShape(Rectangle())
      .gesture (
        DragGesture()
          .onChanged { value in
            if timerManager.periodState == .idle {
              viewModel.handleDragGesture(with: value.translation.height, periodType: timerManager.periodType)
            }
          }
          .onEnded { _ in
            viewModel.endDragGesture()
          }
      )
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
    .environment(SettingsViewModel(settingsManager: .shared))
    .tint(.purpleBrand)
}
