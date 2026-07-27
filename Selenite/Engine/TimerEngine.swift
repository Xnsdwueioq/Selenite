//
//  TimerEngine.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import Foundation
import FocusCore
import OSLog

@MainActor
@Observable
final class TimerEngine {
  private(set) var state: TimerState
  private let effectRunner: EffectRunning
  private let timerConfig: () -> TimerConfig
  private let now: () -> Date
  private let makeID: @Sendable () -> UUID
  private var currentTask: Task<Void, Never>?

  init(
    effectRunner: EffectRunning,
    snapshotReader: SnapshotReading,
    timerConfig: @escaping () -> TimerConfig,
    now: @escaping () -> Date,
    makeID: @escaping @Sendable () -> UUID
  ) {
    self.state = snapshotReader.read() ?? TimerState(config: timerConfig())
    self.effectRunner = effectRunner
    self.timerConfig = timerConfig
    self.now = now
    self.makeID = makeID
  }
  
  func send(_ event: TimerEvent) async {
    let timerContext = TimerContext(now: now(), makeID: makeID)
    let (newState, effects) = TimerCore.reduce(state, event, context: timerContext)
    
    scheduleBoundary(for: newState)
    state = newState
    effectRunner.run(effects)
  }
  
  func reconcile() async {
    let timerContext = TimerContext(now: now(), makeID: makeID)
    let (newState, effects) = TimerCore.reconciled(state, context: timerContext)
    
    scheduleBoundary(for: newState)
    state = newState
    effectRunner.run(effects)
  }
  
  private func scheduleBoundary(for newState: TimerState) {
    currentTask?.cancel()

    guard let boundary = newState.currentBoundaryDate else { return }
    let delay = boundary.timeIntervalSince(now())

    currentTask = Task {
      do {
        try await Task.sleep(for: .seconds(delay))
        currentTask = nil
        await reconcile()
      } catch {
        Logger.timerEngine.debug("Будильник границы отменён — состояние сменилось раньше срока")
      }
    }
  }
}
