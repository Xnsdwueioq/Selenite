//
//  EffectRunner.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import FocusCore

@MainActor protocol EffectRunning {
  func run(_ effects: [TimerEffect]) async
}


@MainActor
final class EffectRunner: EffectRunning {
  func run(_ effects: [TimerEffect]) async {
    // TODO: Running effects
    // gate по calendar
  }
}
