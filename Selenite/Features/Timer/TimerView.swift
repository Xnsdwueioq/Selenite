//
//  TimerView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import SwiftUI
import FocusCore

struct TimerView: View {
  @Environment(TimerEngine.self) private var timerEngine
  @Environment(\.appFlags) private var appFlags
  @Environment(NotificationStatusStore.self) private var notificationStatusStore
  
  @State private var isNotificationsExplaining = false
  
  private var state: TimerState {
    timerEngine.state
  }
  
  var body: some View {
    VStack {
      NotificationStatusWarningView(status: notificationStatusStore.status)
      timeDisplay
        .font(.largeTitle)
        .fontDesign(.rounded)
        .monospacedDigit()

      if #available(iOS 26.0, *) {
        controls.buttonStyle(.glassProminent)
      } else {
        controls.buttonStyle(.borderedProminent)
      }
    }
    .sheet(
      isPresented: $isNotificationsExplaining
    ) {
      NotificationExplainingView(
        notNow: {
          isNotificationsExplaining = false
        },
        submit: {
          isNotificationsExplaining = false
          Task {
            await notificationStatusStore.requestAuthorization()
          }
        }
      )
      .presentationDetents([.medium])
    }
  }

  @ViewBuilder
  private var controls: some View {
    HStack {
      switch state.phase {
      case .finished:
        skipForwardButton
      default:
        skipBackwardButton
        toggleButton
        skipForwardButton
        restartCycleButton
      }
    }
  }
  
  @ViewBuilder
  private var timeDisplay: some View {
    switch TimerDisplay.reading(for: state) {
    case .counting(let boundary):
      TimelineView(.periodic(from: .now, by: 1)) { context in
        clock(max(0, boundary.timeIntervalSince(context.date)))
      }
    case .frozen(let remaining), .upcoming(let remaining):
      clock(remaining)
    case .done:
      clock(0)
    }
  }
  
  private var toggleButton: some View {
    Button {
      Task {
        await timerEngine.send(.toggle)
        await offerNotificationsIfNeeded()
      }
    } label: {
      Image(systemName: state.isRunning ? "pause" : "play")
    }
    .disabled(state.phase == .finished)
  }
  
  private var skipForwardButton: some View {
    Button {
      Task { await timerEngine.send(.skipForward(saveCurrent: true)) } // TODO: Insert Action
    } label: {
      Image(systemName: "chevron.right")
    }
  }
  
  private var skipBackwardButton: some View {
    Button {
      Task { await timerEngine.send(.skipBackward(saveCurrent: true)) } // TODO: Insert Action
    } label: {
      Image(systemName: "chevron.left")
    }
  }
  
  private var restartCycleButton: some View {
    Button {
      Task { await timerEngine.send(.restartCycle) }
    } label: {
      Image(systemName: "arrow.counterclockwise")
    }
  }
  
  private func clock(_ remaining: TimeInterval) -> Text {
    Text(
      Duration.seconds(remaining.rounded(.down)),
      format: .time(pattern: .minuteSecond(padMinuteToLength: 2))
    )
  }
  
  private func offerNotificationsIfNeeded() async {
    let notificationStatus = await NotificationAuthorization.current()
    if !appFlags.didExplainNotifications
        && notificationStatus.authorization == .notDetermined {
      appFlags.didExplainNotifications = true
      isNotificationsExplaining = true
    }
  }
}

#Preview {
  let timerEngine = TimerEngine(
    effectRunner: EffectRunner(
      snapshotWriter: SharedSnapshotStore(),
      notificationScheduler: LocalNotificationScheduler(now: { Date() })
    ),
    snapshotReader: SharedSnapshotStore(),
    timerConfig: { TimerConfig.default },
    now: { Date() },
    makeID: { UUID() }
  )
  TimerView()
    .environment(timerEngine)
    .environment(NotificationStatusStore())
    .environment(\.appFlags, AppFlags(store: UserDefaults(suiteName: UUID().uuidString)!))
}
