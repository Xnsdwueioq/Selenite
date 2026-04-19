//
//  SettingsTabView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct SettingsTabView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(TimerManager.self) private var timerManager
  @Environment(AppSettings.self) private var appSettings
  @Environment(AppCoordinator.self) private var appCoordinator
  
  @State private var viewModel: SettingsViewModel?
  @State private var calendarSyncViewModel: CalendarSyncViewModel
  
  init(
    appSettings: AppSettings,
    manager: EventKitManager = EventKitManager.shared,
    appCoordinator: AppCoordinator,
    calendarService: CalendarService
  ) {
    self._calendarSyncViewModel = State(initialValue: CalendarSyncViewModel(appSettings: appSettings, appCoordinator: appCoordinator, calendarService: calendarService))
  }

  var body: some View {
    @Bindable var appSettings = appSettings
    @Bindable var settingsCoordinator = appCoordinator.settingsCoordindator
    
    let selectedAlert = appCoordinator.settingsCoordindator.selectedAlert
    
    NavigationStack {
      List {
        SessionDurationSettingsView()
        BreakDurationSettingsView()
        CalendarSyncView(viewModel: calendarSyncViewModel)

        Button(
          "Очистить историю сессий",
          role: .destructive,
          action: {
            appCoordinator.settingsCoordindator.selectedAlert = .deleteAll
          }
        )
      }
      .navigationTitle("Настройки")
      .alert(
        selectedAlert?.title ?? "Ошибка",
        isPresented: Binding(
          get: { selectedAlert != nil },
          set: { newValue in
            if !newValue { appCoordinator.settingsCoordindator.selectedAlert = nil }
          }
        ),
        presenting: selectedAlert,
        actions: { alertType in
          switch alertType {
          case .deleteAll:
            Button("Подтвердить", role: .destructive) {
              viewModel?.deleteSessionsHistory()
            }
            Button("Отмена", role: .cancel) { }
          }
        },
        message: { alertType in
          Text(alertType.message)
        }
      )
      .sheet(
        isPresented: $settingsCoordinator.isCalendarSelected,
        onDismiss: { settingsCoordinator.onDismissCalendarSelectedSheet(appSettings: appSettings) }
      ) {
        CalendarsSheetView(viewModel: calendarSyncViewModel)
          .presentationDragIndicator(.visible)
          .presentationDetents([.medium, .large])
          .sheet(
            isPresented: $settingsCoordinator.isCalendarCreated
          ) {
            CalendarCreationSheetView(
              newCalendarTitle: $calendarSyncViewModel.newCalendarTitle,
              newCalendarColor: $calendarSyncViewModel.newCalendarColor,
              creationCalendarAction: calendarSyncViewModel.creationCalendarAction,
              isNewCalendarTitleValidate: calendarSyncViewModel.isNewCalendarTitleValidate
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large])
          }
      }
    }
    .onAppear {
      viewModel = SettingsViewModel(modelContext: modelContext)
    }
  }
}

struct SliderParameterView: View {
  var parameterName: String
  @Binding var value: Double
  
  var body: some View {
    VStack {
      HStack {
        Text(parameterName)
        Spacer()
        Text(String(Int(value)))
          .foregroundStyle(.secondary)
      }
      Slider(
        value: $value,
        in: 1...120,
        label: {
          Text(parameterName)
        },
        currentValueLabel: {
          Text(String(value))
        }
      )
    }
  }
}
struct ToggleParameterView: View {
  var parameterName: String
  @Binding var value: Bool
  
  var body: some View {
    Toggle(parameterName, isOn: $value)
  }
}
