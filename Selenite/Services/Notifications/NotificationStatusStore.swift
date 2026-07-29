//
//  NotificationStatusStore.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/29/26.
//

import Foundation

@Observable
final class NotificationStatusStore {
  private(set) var status: NotificationStatus?

  func refresh() async {
    status = await NotificationAuthorization.current()
  }
  
  func requestAuthorization() async {
    status = await NotificationAuthorization.requestAuthorization()
  }
}
