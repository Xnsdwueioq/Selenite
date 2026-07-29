//
//  NotificationAuthorizationTests.swift
//  SeleniteTests
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import Testing
import UserNotifications
@testable import Selenite

@Suite("Трактовка разрешений на уведомления")
struct NotificationAuthorizationTests {

  struct Case: Sendable, CustomTestStringConvertible {
    let name: String
    let settings: NotificationSettingsSnapshot
    let expected: NotificationStatus

    var testDescription: String { name }
  }

  static func settings(
    _ authorizationStatus: UNAuthorizationStatus,
    alert: UNNotificationSetting = .enabled,
    sound: UNNotificationSetting = .enabled,
    lockScreen: UNNotificationSetting = .enabled,
    scheduledDelivery: UNNotificationSetting = .disabled
  ) -> NotificationSettingsSnapshot {
    NotificationSettingsSnapshot(
      authorizationStatus: authorizationStatus,
      alertSetting: alert,
      soundSetting: sound,
      lockScreenSetting: lockScreen,
      scheduledDeliverySetting: scheduledDelivery
    )
  }

  static let cases: [Case] = [
    Case(
      name: "не спрашивали",
      settings: settings(.notDetermined),
      expected: NotificationStatus(authorization: .notDetermined)
    ),
    Case(
      name: "не спрашивали — проблемы доставки не считаем",
      settings: settings(.notDetermined, alert: .disabled, sound: .disabled),
      expected: NotificationStatus(authorization: .notDetermined)
    ),
    Case(
      name: "отказано — проблемы доставки не считаем",
      settings: settings(.denied, alert: .disabled, sound: .disabled),
      expected: NotificationStatus(authorization: .denied)
    ),
    Case(
      name: "разрешено, всё включено",
      settings: settings(.authorized),
      expected: NotificationStatus(authorization: .authorized)
    ),
    Case(
      name: "звук выключен пользователем",
      settings: settings(.authorized, sound: .disabled),
      expected: NotificationStatus(authorization: .authorized, issues: [.soundDisabled])
    ),
    Case(
      name: "баннеры выключены",
      settings: settings(.authorized, alert: .disabled),
      expected: NotificationStatus(authorization: .authorized, issues: [.alertsDisabled])
    ),
    Case(
      name: "экран блокировки выключен",
      settings: settings(.authorized, lockScreen: .disabled),
      expected: NotificationStatus(authorization: .authorized, issues: [.lockScreenDisabled])
    ),
    Case(
      name: "сводка по расписанию включена",
      settings: settings(.authorized, scheduledDelivery: .enabled),
      expected: NotificationStatus(authorization: .authorized, issues: [.scheduledDelivery])
    ),
    Case(
      name: "сломано всё сразу",
      settings: settings(
        .authorized,
        alert: .disabled,
        sound: .disabled,
        lockScreen: .disabled,
        scheduledDelivery: .enabled
      ),
      expected: NotificationStatus(
        authorization: .authorized,
        issues: [.alertsDisabled, .soundDisabled, .lockScreenDisabled, .scheduledDelivery]
      )
    ),
    Case(
      name: "notSupported проблемой не считается",
      settings: settings(
        .authorized,
        alert: .notSupported,
        sound: .notSupported,
        lockScreen: .notSupported
      ),
      expected: NotificationStatus(authorization: .authorized)
    ),
    Case(
      name: "временное разрешение",
      settings: settings(.provisional, sound: .disabled),
      expected: NotificationStatus(authorization: .authorized, issues: [.soundDisabled])
    ),
    Case(
      name: "эфемерное разрешение",
      settings: settings(.ephemeral),
      expected: NotificationStatus(authorization: .authorized)
    ),
  ]

  @Test(arguments: cases)
  func status(_ testCase: Case) {
    #expect(NotificationAuthorization.status(for: testCase.settings) == testCase.expected)
  }
}
