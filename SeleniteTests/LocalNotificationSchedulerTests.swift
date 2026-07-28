//
//  LocalNotificationSchedulerTests.swift
//  SeleniteTests
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import Foundation
import Testing
import UserNotifications
import FocusCore
@testable import Selenite

@Suite("Планировщик локальных уведомлений")
struct LocalNotificationSchedulerTests {

  static let now = Date(timeIntervalSince1970: 1_785_000_000)
  static let quota = 40

  private let scheduler = LocalNotificationScheduler(now: { now })

  private func boundary(offset: TimeInterval) -> PhaseBoundary {
    PhaseBoundary(
      endingPhase: .work(index: 0),
      completionAt: Self.now.addingTimeInterval(offset),
      nextPhase: .shortBreak(afterIndex: 0),
      nextPhaseDuration: 5 * 60,
      nextPhaseStartsAutomatically: true
    )
  }

  private func identifier(offset: TimeInterval) -> String {
    "boundary.\(Int(Self.now.timeIntervalSince1970 + offset))"
  }

  @Test("идентификаторы в цепочке различны")
  func identifiersAreUnique() {
    let boundaries = (1...5).map { boundary(offset: TimeInterval($0) * 300) }

    let requests = scheduler.requests(for: boundaries)

    #expect(requests.count == 5)
    #expect(Set(requests.map(\.identifier)).count == 5)
  }

  @Test("план длиннее квоты обрезается")
  func quotaIsEnforced() {
    let boundaries = (1...50).map { boundary(offset: TimeInterval($0) * 300) }

    #expect(scheduler.requests(for: boundaries).count == Self.quota)
  }

  @Test("просроченная граница отбрасывается, будущие за ней остаются")
  func pastBoundaryIsSkippedAndLaterOnesSurvive() {
    let boundaries = [boundary(offset: -10), boundary(offset: 10), boundary(offset: 20)]

    let requests = scheduler.requests(for: boundaries)

    #expect(requests.map(\.identifier) == [identifier(offset: 10), identifier(offset: 20)])
  }

  @Test("граница ровно в now принадлежит прошлому и не планируется")
  func boundaryAtNowIsNotScheduled() {
    #expect(scheduler.requests(for: [boundary(offset: 0)]).isEmpty)
  }

  @Test("интервал триггера равен расстоянию от now до границы")
  func triggerIntervalMatchesDistanceToBoundary() throws {
    let requests = scheduler.requests(for: [boundary(offset: 1500)])

    let trigger = try #require(requests.first?.trigger as? UNTimeIntervalNotificationTrigger)
    #expect(trigger.timeInterval == 1500)
    #expect(trigger.repeats == false)
  }

  @Test("уведомление несёт звук и текст границы")
  func requestCarriesSoundAndContent() throws {
    let boundary = boundary(offset: 300)

    let request = try #require(scheduler.requests(for: [boundary]).first)

    let expected = NotificationContentBuilder.content(for: boundary)
    #expect(request.content.title == expected.title)
    #expect(request.content.body == expected.body)
    #expect(request.content.sound == .default)
  }

  @Test("снимаются только свои идентификаторы")
  func ownIdentifiersFiltersByPrefix() {
    let pending = ["boundary.100", "streak.boundary.200", "boundary.300", "streak.400"]
      .map {
        UNNotificationRequest(
          identifier: $0,
          content: UNMutableNotificationContent(),
          trigger: nil
        )
      }

    #expect(scheduler.ownIdentifiers(from: pending) == ["boundary.100", "boundary.300"])
  }
}
