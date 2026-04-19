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
  @State private var eventKitManager = EventKitManager.shared
  @State private var viewModel: ContentViewModel?
  
  @State private var calendarService = CalendarService(eventStore: EventKitManager.shared.eventStore)
  @State private var eventsService = EventsService(eventStore: EventKitManager.shared.eventStore)
  
  var body: some View {
    let selectedAlert = appCoordinator.selectedAlert
    
    TabsView()
      .onAppear {
        timerManager.modelContext = modelContext
        timerManager.eventsService = eventsService
        calendarService.appSettings = appSettings
        viewModel = ContentViewModel(appCoordinator: appCoordinator, appSettings: appSettings, calendarService: calendarService)
      }
      .environment(appSettings)
      .environment(appCoordinator)
      .environment(timerManager)
      .environment(calendarService)
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
              appCoordinator.openCalendarSelectionSheet()
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
