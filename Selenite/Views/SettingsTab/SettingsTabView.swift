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
  @State private var viewModel: SettingsViewModel?
  @State private var activeAlert: ActiveAlert?
  
  private var sessionCountWithLimits: Binding<Double> {
    Binding(
      get: { appSettings.sessionCount },
      set: { newValue in
        let minAllowed = Double(timerManager.getCurrentSessionNumber())
        appSettings.sessionCount = max(newValue, minAllowed)
      }
    )
  }
  
  var body: some View {
    @Bindable var appSettings = appSettings
    
    NavigationStack {
      List {
        Section("Сессия") {
          SliderParameterView(parameterName: "Продолжительность сессии", value: $appSettings.sessionDuration)
          VStack {
            HStack {
              Text("Количество сессий")
              Spacer()
              Text(String(Int(appSettings.sessionCount)))
                .foregroundStyle(.secondary)
            }
            
            Slider(
              value: sessionCountWithLimits,
              in: 1...10,
              step: 1,
              label: {
                Text("Количество сесий")
              },
              currentValueLabel: {
                Text(String(appSettings.sessionCount))
              }
            )
          }
          ToggleParameterView(parameterName: "Автоматический старт сессии", value: $appSettings.sessionAutostart)
        }
        
        Section("Перерывы") {
          ToggleParameterView(parameterName: "Отключить перерывы", value: $appSettings.areBreaksDisabled)
          if !appSettings.areBreaksDisabled {
            SliderParameterView(parameterName: "Короткий перерыв", value: $appSettings.shortBreakDuration)
            SliderParameterView(parameterName: "Длинный перерыв", value: $appSettings.longBreakDuration)
            ToggleParameterView(parameterName: "Автоматический старт перерыва", value: $appSettings.breakAutostart)
          }
        }
        Button(
          "Очистить историю сессий",
          role: .destructive,
          action: {
            activeAlert = .deleteAll
          }
        )
      }
      .animation(.snappy, value: appSettings.areBreaksDisabled)
      .navigationTitle("Настройки")
      .alert(
        activeAlert?.alertTitle ?? "",
        isPresented: Binding(
          get: { activeAlert != nil },
          set: { if !$0 { activeAlert = nil } }
        ),
        presenting: activeAlert
      ) { alert in
        switch alert {
        case .deleteAll:
          Button("Подтвердить", role: .destructive) {
              viewModel?.deleteSessionsHistory()
          }
          Button("Отмена", role: .cancel) { }
        }
      } message: { alert in
        if let message = alert.alertMessage {
          Text(message)
        }
      }
    }
    .onAppear {
      viewModel = SettingsViewModel(modelContext: modelContext)
    }
  }
  
  private enum ActiveAlert {
    case deleteAll
    
    var alertTitle: String {
      switch self {
      case .deleteAll:
        return "Очистить историю сессий?"
      }
    }
    
    var alertMessage: String? {
      switch self {
      case .deleteAll:
        return "Все записанные сессии будут удалены безвозвратно."
      }
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
  SettingsTabView()
    .modelContainer(for: [Period.self, PeriodInterval.self])
    .environment(TimerManager(settingsManager: SettingsManager.shared))
    .environment(AppSettings(settingsManager: .shared))
    .tint(.purple.mix(with: .red, by: 0.6))
}
