//

import SwiftUI
import FocusCore

@main
struct SeleniteApp: App {
  // TODO: Заполнение TimerConfig из SettingsStore
  @State private var timerEngine = TimerEngine(
    state: TimerState(config: TimerConfig.default),
    effectRunner: EffectRunner(),
    now: { Date() },
    makeID: { UUID() }
  )
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .environment(timerEngine)
  }
}
