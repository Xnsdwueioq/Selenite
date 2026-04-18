//
//  ContentView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var timerManager = TimerManager(settingsManager: .shared)
  @State private var appSettings = AppSettings(settingsManager: .shared)
  @State private var appCoordinator = AppCoordinator()
  
  var body: some View {
    let selectedAlert = appCoordinator.selectedAlert
    
    TabsView()
      .environment(appSettings)
      .environment(appCoordinator)
      .environment(timerManager)
      .onAppear {
        timerManager.modelContext = modelContext
      }
      .alert(
        selectedAlert?.title ?? "Ошибка",
        isPresented: Binding(
          get: { selectedAlert != nil },
          set: { newValue in
            if !newValue { appCoordinator.selectedAlert = nil }
          }
        ),
        presenting: selectedAlert,
        actions: { alertType in
          switch alertType {
          case .noAccessToCalendar:
            Button("Перейти в настройки", role: .confirm) {
              Task {
                await appCoordinator.openSystemSettings()
              }
            }
            Button("Ок", role: .close) { }
          case .nilCalendarSelected:
            Button("Выбрать календарь", role: .cancel) {
              // TODO: Открыть выбор календарей
            }
            Button("Выключить синхронизацию", role: .destructive) {
              appSettings.synchronizeCalendar = false
            }
          }
        },
        message: { alertType in
          Text(alertType.message)
        }
      )
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
  
  ContentView()
    .modelContainer(container)
    .environment(previewManager)
    .environment(AppSettings(settingsManager: .shared))
    .tint(.purpleBrand)
}
