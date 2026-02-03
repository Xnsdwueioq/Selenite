//
//  SettingsTabView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct SettingsTabView: View {
  @Environment(TimerManager.self) private var timerManager
  @State private var settingsVM = SettingsTabViewModel(settingsManager: SettingsManager.shared)
  
  private var sessionCountBinding: Binding<Double> {
    Binding(
      get: { settingsVM.sessionCount },
      set: { newValue in
        let minAllowed = Double(timerManager.getCurrentSessionNumber())
        // Валидация: не даем упасть ниже текущей сессии
        settingsVM.sessionCount = max(newValue, minAllowed)
      }
    )
  }
  
  var body: some View {
    NavigationStack {
      List {
        Section("Сессия") {
          SliderParameterView(parameterName: "Продолжительность сессии", value: $settingsVM.sessionDuration)
          VStack {
            HStack {
              Text("Количество сессий")
              Spacer()
              Text(String(Int(settingsVM.sessionCount)))
                .foregroundStyle(.secondary)
            }
            
            Slider(
              value: sessionCountBinding,
              in: 1...10,
              step: 1,
              label: {
                Text("Количество сесий")
              },
              currentValueLabel: {
                Text(String(settingsVM.sessionCount))
              }
            )
          }
          ToggleParameterView(parameterName: "Автоматический старт сессии", value: $settingsVM.sessionAutostart)
        }
        
        Section("Перерывы") {
          ToggleParameterView(parameterName: "Отключить перерывы", value: $settingsVM.areBreaksDisabled)
          if !settingsVM.areBreaksDisabled {
            SliderParameterView(parameterName: "Короткий перерыв", value: $settingsVM.shortBreakDuration)
            SliderParameterView(parameterName: "Длинный перерыв", value: $settingsVM.longBreakDuration)
            ToggleParameterView(parameterName: "Автоматический старт перерыва", value: $settingsVM.breakAutostart)
          }
        }
      }
      .animation(.snappy, value: settingsVM.areBreaksDisabled)
      .navigationTitle("Настройки")
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
        in: 1...100,
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
    .tint(.purple.mix(with: .red, by: 0.6))
}
