//

import SwiftUI
import FocusCore

@main
struct SeleniteApp: App {
  @Environment(\.scenePhase) private var scenePhase
  
  // TODO: Заполнение TimerConfig из SettingsStore
  @State private var timerEngine = TimerEngine(
    effectRunner: EffectRunner(),
    timerConfig: { TimerConfig.default },
    now: { Date() },
    makeID: { UUID() }
  )
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .task { await timerEngine.reconcile() }
    }
    .environment(timerEngine)
    .onChange(of: scenePhase) { old, _ in
      if old == .background {
        Task { await timerEngine.reconcile() }
      }
    }
  }
}
