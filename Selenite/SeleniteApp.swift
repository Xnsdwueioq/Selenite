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
  @State private var notificationStatusStore = NotificationStatusStore()
  private let appFlags = AppFlags()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .task {
          await timerEngine.reconcile()
          await notificationStatusStore.refresh()
        }
    }
    .environment(timerEngine)
    .environment(notificationStatusStore)
    .environment(\.appFlags, appFlags)
    .onChange(of: scenePhase) { _, new in
      if new == .active {
        Task {
          await timerEngine.reconcile()
          await notificationStatusStore.refresh()
        }
      }
    }
  }
}
