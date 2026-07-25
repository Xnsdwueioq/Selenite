//
//  TimerEngine.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import Foundation
import FocusCore

@MainActor
@Observable
final class TimerEngine {
  private(set) var state: TimerState
  private let effectRunner: EffectRunning
  private let now: () -> Date
  private let makeID: @Sendable () -> UUID
  
  init(
    state: TimerState,
    effectRunner: EffectRunning,
    now: @escaping () -> Date,
    makeID: @escaping @Sendable () -> UUID
  ) {
    self.state = state
    self.effectRunner = effectRunner
    self.now = now
    self.makeID = makeID
  }
  
  func send(_ event: TimerEvent) async {
    let timerContext = TimerContext(now: now(), makeID: makeID)
    let (newState, effects) = TimerCore.reduce(state, event, context: timerContext)
    
    state = newState
    await effectRunner.run(effects)
  }
  
  func reconcile() async {
    let timerContext = TimerContext(now: now(), makeID: makeID)
    let (newState, effects) = TimerCore.reconciled(state, context: timerContext)
    
    state = newState
    await effectRunner.run(effects)
  }
}
