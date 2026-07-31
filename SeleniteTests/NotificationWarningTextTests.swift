//
//  NotificationWarningTextTests.swift
//  SeleniteTests
//
//  Created by Eyhciurmrn Zmpodackrl on 7/31/26.
//

import Testing
@testable import Selenite

@Suite("Выбор текста предупреждения")
struct NotificationWarningTextTests {

  struct Case: Sendable, CustomTestStringConvertible {
    let name: String
    let issues: Set<NotificationDeliveryIssue>
    let expected: String

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
      name: "сводка перебивает полную невидимость",
      issues: Set(NotificationDeliveryIssue.allCases),
      expected: NotificationDeliveryIssue.scheduledDelivery.warningText
    ),
    Case(
      name: "сводка перебивает полную тишину",
      issues: [.scheduledDelivery, .soundDisabled, .alertsDisabled, .lockScreenDisabled],
      expected: NotificationDeliveryIssue.scheduledDelivery.warningText
    ),
    Case(
      name: "сводка перебивает одиночную проблему",
      issues: [.scheduledDelivery, .lockScreenDisabled],
      expected: NotificationDeliveryIssue.scheduledDelivery.warningText
    ),
    Case(
      name: "не остаётся ни одного канала",
      issues: [.soundDisabled, .alertsDisabled, .lockScreenDisabled, .notificationCenterDisabled],
      expected: NotificationDeliveryIssue.noChannelsWarningText
    ),
    Case(
      name: "остаётся только звук",
      issues: [.alertsDisabled, .lockScreenDisabled, .notificationCenterDisabled],
      expected: NotificationDeliveryIssue.soundOnlyWarningText
    ),
    Case(
      name: "остаётся только центр уведомлений",
      issues: [.soundDisabled, .alertsDisabled, .lockScreenDisabled],
      expected: NotificationDeliveryIssue.notificationCenterOnlyWarningText
    ),
    Case(
      name: "неполный набор до тишины — самая тяжёлая одиночная",
      issues: [.soundDisabled, .alertsDisabled],
      expected: NotificationDeliveryIssue.soundDisabled.warningText
    ),
    Case(
      name: "пара без композита — самая тяжёлая одиночная",
      issues: [.alertsDisabled, .lockScreenDisabled],
      expected: NotificationDeliveryIssue.alertsDisabled.warningText
    ),
  ]

  @Test("без проблем текста нет")
  func noIssues() {
    #expect(NotificationDeliveryIssue.warningText(for: []) == nil)
  }

  @Test("одиночная проблема даёт свой собственный текст", arguments: NotificationDeliveryIssue.allCases)
  func singleIssue(_ issue: NotificationDeliveryIssue) {
    #expect(NotificationDeliveryIssue.warningText(for: [issue]) == issue.warningText)
  }

  @Test(arguments: cases)
  func warningText(_ testCase: Case) {
    #expect(NotificationDeliveryIssue.warningText(for: testCase.issues) == testCase.expected)
  }

  @Test("для любого непустого набора текст есть", arguments: allNonEmptySubsets)
  func everySubsetHasText(_ issues: Set<NotificationDeliveryIssue>) {
    #expect(NotificationDeliveryIssue.warningText(for: issues) != nil)
  }

  @Test("тексты проблем попарно различны")
  func issueTextsAreDistinct() {
    let texts = NotificationDeliveryIssue.allCases.map(\.warningText)
    #expect(Set(texts).count == texts.count)
  }

  @Test("композитные тексты не совпадают с одиночными и друг с другом")
  func compositeTextsAreDistinct() {
    let issueTexts = Set(NotificationDeliveryIssue.allCases.map(\.warningText))

    for composite in Self.compositeTexts {
      #expect(!issueTexts.contains(composite))
    }

    #expect(Set(Self.compositeTexts).count == Self.compositeTexts.count)
  }

  @Test("каждое композитное сообщение достижимо хотя бы одним набором")
  func everyCompositeTextIsReachable() {
    let produced = Set(Self.allNonEmptySubsets.compactMap { NotificationDeliveryIssue.warningText(for: $0) })

    for composite in Self.compositeTexts {
      #expect(produced.contains(composite))
    }
  }

  static let compositeTexts: [String] = [
    NotificationDeliveryIssue.noChannelsWarningText,
    NotificationDeliveryIssue.soundOnlyWarningText,
    NotificationDeliveryIssue.notificationCenterOnlyWarningText,
  ]
}
