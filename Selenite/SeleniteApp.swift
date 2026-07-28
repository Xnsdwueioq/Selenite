//

import SwiftUI
import FocusCore

@main
struct SeleniteApp: App {
  @Environment(\.scenePhase) private var scenePhase
  
  // TODO: Заполнение TimerConfig из SettingsStore
  @State private var timerEngine = TimerEngine(
    effectRunner: EffectRunner(
      snapshotWriter: SharedSnapshotStore(),
      notificationScheduler: LocalNotificationScheduler(now: { Date() })
    ),
    snapshotReader: SharedSnapshotStore(),
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
      if old != .active {
        Task { await timerEngine.reconcile() }
      }
    }
  }
}
