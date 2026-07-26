// Schedule.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 7/24/26.

import Foundation

/// План будущих границ фаз — для перепланирования локальных уведомлений.
enum Schedule {

  /// Границы фаз, которые наступят после `now`, начиная с ближайшей.
  ///
  /// - Ручной режим (`autoAdvance == false`): ровно одна ближайшая граница —
  ///   дальше цикл встаёт в `.awaiting` и следующую границу знать нельзя.
  /// - Авто-режим: вся цепочка до `.finished` включительно.
  /// - Пауза / `idle` / `awaiting` / `finished`: пустой план (границ нет).
  static func boundaries(for state: TimerState, now: Date) -> [PhaseBoundary] {
    guard let firstBoundary = state.currentBoundaryDate, firstBoundary > now else { return [] }

    let config = state.config
    var boundaries: [PhaseBoundary] = []

    // Ближайшая граница — конец текущей фазы.
    boundaries.append(
      PhaseBoundary(
        completionAt: firstBoundary,
        nextPhase: PhaseSequence.next(after: state.phase, config: config)
      )
    )

    // Дальше цепочку можно продолжать, только если фазы стартуют сами.
    guard config.autoAdvance else { return boundaries }

    while let last = boundaries.last, last.nextPhase != .finished {
      guard let duration = config.duration(of: last.nextPhase) else { break }
      boundaries.append(
        PhaseBoundary(
          completionAt: last.completionAt + duration,
          nextPhase: PhaseSequence.next(after: last.nextPhase, config: config)
        )
      )
    }

    return boundaries
  }
}
