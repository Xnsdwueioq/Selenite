//
//  BreakDurationSettingsView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 19.04.2026.
//

import SwiftUI

struct BreakDurationSettingsView: View {
  @Environment(AppSettings.self) private var appSettings
  
  var body: some View {
    @Bindable var appSettings = appSettings
    
    Section("Перерывы") {
      ToggleParameterView(parameterName: "Отключить перерывы", value: $appSettings.areBreaksDisabled.animation(.snappy))
      if !appSettings.areBreaksDisabled {
        SliderParameterView(parameterName: "Короткий перерыв", value: $appSettings.shortBreakDuration)
        SliderParameterView(parameterName: "Длинный перерыв", value: $appSettings.longBreakDuration)
        ToggleParameterView(parameterName: "Автоматический старт перерыва", value: $appSettings.breakAutostart)
      }
    }
  }
}

#Preview {
  BreakDurationSettingsView()
}
