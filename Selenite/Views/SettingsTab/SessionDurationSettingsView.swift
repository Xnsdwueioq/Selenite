//
//  SessionDurationSettingsView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 19.04.2026.
//

import SwiftUI

struct SessionDurationSettingsView: View {
  @Environment(TimerManager.self) private var timerManager
  @Environment(AppSettings.self) private var appSettings

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
  }
}
