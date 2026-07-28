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
    let authorization: UNAuthorizationStatus
    let sound: UNNotificationSetting
    let expected: NotificationStatusResponse

    var testDescription: String { name }
  }

  static let cases: [Case] = [
    Case(
      name: "не спрашивали",
      authorization: .notDetermined,
      sound: .notSupported,
      expected: .notDetermined
    ),
    Case(
      name: "не спрашивали — статус важнее звука",
      authorization: .notDetermined,
      sound: .enabled,
      expected: .notDetermined
    ),
    Case(
      name: "отказано",
      authorization: .denied,
      sound: .notSupported,
      expected: .denied
    ),
    Case(
      name: "разрешено со звуком",
      authorization: .authorized,
      sound: .enabled,
      expected: .authorizedWithSound
    ),
    Case(
      name: "разрешено, звук выключен пользователем",
      authorization: .authorized,
      sound: .disabled,
      expected: .authorizedWithoutSound
    ),
    Case(
      name: "разрешено, звук не поддерживается",
      authorization: .authorized,
      sound: .notSupported,
      expected: .authorizedWithoutSound
    ),
    Case(
      name: "временное разрешение всегда беззвучно",
      authorization: .provisional,
      sound: .enabled,
      expected: .authorizedWithoutSound
    ),
    Case(
      name: "эфемерное разрешение всегда беззвучно",
      authorization: .ephemeral,
      sound: .enabled,
      expected: .authorizedWithoutSound
    ),
  ]

  @Test(arguments: cases)
  func status(_ testCase: Case) async {
    let status = NotificationAuthorization.status(
      authorizationStatus: testCase.authorization,
      soundSetting: testCase.sound
    )

    #expect(status == testCase.expected)
  }
}
