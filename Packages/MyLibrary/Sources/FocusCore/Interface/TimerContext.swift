// TimerContext.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 10.07.2026.

import Foundation

/// Внешние (недетерминированные) зависимости ядра.
///
/// Их значения втекают в `reduce` снаружи, чтобы редьюсер оставался чистой
/// функцией.
public struct TimerContext: Sendable {
  /// Единый момент «сейчас».
  public var now: Date

  /// Фабрика идентификатора цикла.
  public var makeID: @Sendable () -> UUID

  public init(
    now: Date,
    makeID: @escaping @Sendable () -> UUID = { UUID() }
  ) {
    self.now = now
    self.makeID = makeID
  }
}
