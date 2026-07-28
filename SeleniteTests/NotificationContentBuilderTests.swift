//
//  NotificationContentBuilderTests.swift
//  SeleniteTests
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import Testing
import FocusCore
@testable import Selenite

@Suite("Тексты уведомлений на границах фаз")
struct NotificationContentBuilderTests {

  @Test(arguments: NotificationSamples.all)
  func content(_ sample: NotificationSamples.Sample) {
    let content = NotificationContentBuilder.content(for: sample.boundary)

    #expect(content.title == sample.title)
    #expect(content.body == sample.body)
  }
}
