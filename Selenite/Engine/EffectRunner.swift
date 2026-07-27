//
//  EffectRunner.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/25/26.
//

import FocusCore
import OSLog

@MainActor protocol EffectRunning {
  /// Ставит серию эффектов в очередь и сразу возвращается.
  /// Серии исполняются строго по одной, FIFO.
  func run(_ effects: [TimerEffect])
}

@MainActor
final class EffectRunner: EffectRunning {
  /// Хвост очереди: каждая новая серия ждёт полного завершения предыдущей.
  private var tail: Task<Void, Never>?
  
  private let snapshotWriter: SnapshotWriting
  private let notificationScheduler: NotificationScheduling
  
  init(
    snapshotWriter: SnapshotWriting,
    notificationScheduler: NotificationScheduling
  ) {
    self.snapshotWriter = snapshotWriter
    self.notificationScheduler = notificationScheduler
  }

  func run(_ effects: [TimerEffect]) {
    guard !effects.isEmpty else { return }

    let previous = tail
    tail = Task { [weak self] in
      await previous?.value
      await self?.perform(effects)
    }
  }

  /// Ждёт, пока очередь опустеет. Для тестов и отладки.
  func drain() async {
    await tail?.value
  }

  /// Эффекты одной пачки идут строго по порядку массива —
  /// веер канонически упорядочен (снапшот первым, reloadWidgets последним).
  private func perform(_ effects: [TimerEffect]) async {
    for effect in effects {
      await perform(effect)
    }
  }

  private func perform(_ effect: TimerEffect) async {
    switch effect {
    case .persistSnapshot(let state):
      Logger.effects.debug("The 'persistSnapshot' effect was triggered")
      await snapshotWriter.write(state)

    case .saveCompleted:
      Logger.effects.debug("saveCompleted — TODO")

    case .addCalendarEvent:
      // TODO: Гейтить эффект
      Logger.effects.debug("addCalendarEvent — TODO: гейт по настройке")

    case .rescheduleNotifications(let boundaries):
      Logger.effects.debug("The 'rescheduleNotifications' effect was triggered")
      await notificationScheduler.reschedule(to: boundaries)

    case .cancelNotifications:
      Logger.effects.debug("The 'cancelNotifications' effect was triggered")
      await notificationScheduler.cancelAll()

    case .syncLiveActivity:
      Logger.effects.debug("syncLiveActivity — TODO")

    case .pushToWatch:
      Logger.effects.debug("pushToWatch — TODO")

    case .reloadWidgets:
      Logger.effects.debug("reloadWidgets — TODO")
    }
  }
}
