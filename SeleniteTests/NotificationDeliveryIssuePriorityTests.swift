//
//  NotificationDeliveryIssuePriorityTests.swift
//  SeleniteTests
//
//  Created by Eyhciurmrn Zmpodackrl on 7/29/26.
//

import Testing
@testable import Selenite

@Suite("Приоритет проблем доставки")
struct NotificationDeliveryIssuePriorityTests {

  struct Case: Sendable, CustomTestStringConvertible {
    let name: String
    let issues: Set<NotificationDeliveryIssue>
    let expected: NotificationDeliveryIssue

    var testDescription: String { name }
  }

  static let allNonEmptySubsets: [Set<NotificationDeliveryIssue>] = {
    let all = NotificationDeliveryIssue.allCases
    return (1 ..< (1 << all.count)).map { mask in
      Set(all.enumerated().filter { mask & (1 << $0.offset) != 0 }.map(\.element))
    }
  }()

  static let cases: [Case] = [
    Case(
      name: "сводка важнее выключенных баннеров",
      issues: [.alertsDisabled, .scheduledDelivery],
      expected: .scheduledDelivery
    ),
    Case(
      name: "сводка важнее выключенного звука",
      issues: [.scheduledDelivery, .soundDisabled],
      expected: .scheduledDelivery
    ),
    Case(
      name: "сводка важнее выключенного локскрина",
      issues: [.lockScreenDisabled, .scheduledDelivery],
      expected: .scheduledDelivery
    ),
    Case(
      name: "баннеры важнее звука",
      issues: [.alertsDisabled, .soundDisabled],
      expected: .alertsDisabled
    ),
    Case(
      name: "баннеры важнее локскрина",
      issues: [.alertsDisabled, .lockScreenDisabled],
      expected: .alertsDisabled
    ),
    Case(
      name: "звук важнее локскрина",
      issues: [.soundDisabled, .lockScreenDisabled],
      expected: .soundDisabled
    ),
    Case(
      name: "тройка со сводкой",
      issues: [.alertsDisabled, .lockScreenDisabled, .scheduledDelivery],
      expected: .scheduledDelivery
    ),
    Case(
      name: "тройка без сводки",
      issues: [.alertsDisabled, .soundDisabled, .lockScreenDisabled],
      expected: .alertsDisabled
    ),
    Case(
      name: "сломано всё сразу",
      issues: Set(NotificationDeliveryIssue.allCases),
      expected: .scheduledDelivery
    ),
  ]

  @Test("список приоритетов покрывает каждый случай ровно один раз")
  func severityOrderIsComplete() {
    #expect(Set(NotificationDeliveryIssue.bySeverity) == Set(NotificationDeliveryIssue.allCases))
    #expect(NotificationDeliveryIssue.bySeverity.count == NotificationDeliveryIssue.allCases.count)
  }

  @Test("без проблем показывать нечего")
  func noIssues() {
    #expect(NotificationDeliveryIssue.mostSevere(in: []) == nil)
  }

  @Test("единственная проблема возвращается как есть", arguments: NotificationDeliveryIssue.allCases)
  func singleIssue(_ issue: NotificationDeliveryIssue) {
    #expect(NotificationDeliveryIssue.mostSevere(in: [issue]) == issue)
  }

  @Test(arguments: cases)
  func mostSevere(_ testCase: Case) {
    #expect(NotificationDeliveryIssue.mostSevere(in: testCase.issues) == testCase.expected)
  }

  @Test("для любого непустого набора результат принадлежит набору", arguments: allNonEmptySubsets)
  func resultBelongsToInput(_ issues: Set<NotificationDeliveryIssue>) throws {
    let mostSevere = try #require(NotificationDeliveryIssue.mostSevere(in: issues))
    #expect(issues.contains(mostSevere))
  }
}
