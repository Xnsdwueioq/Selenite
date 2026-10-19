// PhaseSequence.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 7/24/26.

/// Навигация по графу `Phase` при данном `TimerConfig`.
enum PhaseSequence {

  /// Следующая фаза после `phase` без `awaiting`.
  static func next(after phase: Phase, config: TimerConfig) -> Phase {
    switch phase {
    case .work(let index):
      if index >= config.sessionCount - 1 {
        return config.longBreaksEnabled ? .longBreak : .finished
      } else {
        return config.shortBreaksEnabled
          ? .shortBreak(afterIndex: index)
          : .work(index: index + 1)
      }

    case .shortBreak(afterIndex: let index):
      return .work(index: index + 1)

    case .longBreak:
      return .finished

    case .idle:
      return .work(index: 0)

    case .awaiting, .finished:
      return .idle
    }
  }

  /// Предыдущая фаза перед `phase`, или `nil`, если её нет (начало цикла /
  /// терминальные фазы). Используется при шаге назад из `.awaiting`.
  static func previous(before phase: Phase, config: TimerConfig) -> Phase? {
    switch phase {
    case .work(let index):
      if index == 0 { return nil }
      return config.shortBreaksEnabled
        ? .shortBreak(afterIndex: index - 1)
        : .work(index: index - 1)

    case .shortBreak(let afterIndex):
      return .work(index: afterIndex)

    case .longBreak:
      return .work(index: config.sessionCount - 1)

    case .idle, .awaiting, .finished:
      return nil
    }
  }
}
