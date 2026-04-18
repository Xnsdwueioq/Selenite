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
  
  @State private var eventKitManager: EventKitManager
  @State private var calendarSyncViewModel: CalendarSyncViewModel
  
  init(
    manager: EventKitManager = EventKitManager.shared,
    appCoordinator: AppCoordinator
  ) {
    self.eventKitManager = manager
    let calendarService = CalendarService(eventStore: manager.eventStore)
    self._calendarSyncViewModel = State(initialValue:CalendarSyncViewModel(appCoordinator: appCoordinator, calendarService: calendarService))
  }

  var body: some View {
    @Bindable var appSettings = appSettings
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
      .animation(.snappy, value: appSettings.areBreaksDisabled)
      .animation(.snappy, value: appSettings.synchronizeCalendar)
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
        isPresented: $calendarSyncViewModel.isCalendarSelected,
        onDismiss: calendarSyncViewModel.onDismissCalendarSelected
      ) {
        CalendarsSheetView(viewModel: calendarSyncViewModel)
          .presentationDragIndicator(.visible)
          .presentationDetents([.medium, .large])
          .sheet(
            isPresented: $calendarSyncViewModel.isCalendarCreated,
            onDismiss: calendarSyncViewModel.onDismissCalendarCreated
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
      calendarSyncViewModel.checkAuthorisationStatus()
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

#Preview {
  SettingsTabView(appCoordinator: AppCoordinator())
    .modelContainer(for: [Period.self, PeriodInterval.self])
    .environment(TimerManager(settingsManager: SettingsManager.shared))
    .environment(AppSettings(settingsManager: .shared))
    .tint(.purple.mix(with: .red, by: 0.6))
}
