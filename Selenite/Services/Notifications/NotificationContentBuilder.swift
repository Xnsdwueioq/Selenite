//
//  NotificationContentBuilder.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import Foundation
import FocusCore

nonisolated enum NotificationContentBuilder {

  static func content(for boundary: PhaseBoundary) -> (title: String, body: String) {
    (title(for: boundary), body(for: boundary))
  }

  private static func title(for boundary: PhaseBoundary) -> String {
    guard boundary.nextPhase != .finished else {
      return String(localized: "notification.title.cycleFinished", defaultValue: "Цикл завершён")
    }

    switch boundary.endingPhase {
    case .work:
      return String(localized: "notification.title.workFinished", defaultValue: "Сессия завершена")
    case .shortBreak:
      return String(localized: "notification.title.shortBreakFinished", defaultValue: "Перерыв завершён")
    case .longBreak:
      return String(localized: "notification.title.longBreakFinished", defaultValue: "Длинный перерыв завершён")
    case .idle, .awaiting, .finished:
      return String(localized: "notification.title.phaseFinished", defaultValue: "Фаза завершена")
    }
  }

  private static func body(for boundary: PhaseBoundary) -> String {
    guard boundary.nextPhase != .finished else {
      return String(localized: "notification.body.cycleFinished", defaultValue: "Все сессии пройдены. Вернитесь в приложение для старта нового цикла")
    }

    var detail = boundary.nextPhase.displayName
    if let duration = boundary.nextPhaseDuration {
      let length = Duration.seconds(duration)
        .formatted(.units(allowed: [.hours, .minutes], width: .wide))
      detail += ", \(length)"
    }

    return boundary.nextPhaseStartsAutomatically
      ? String(localized: "notification.body.autoNext", defaultValue: "Начинается: \(detail)")
      : String(localized: "notification.body.manualNext", defaultValue: "Далее: \(detail)")
  }
}
