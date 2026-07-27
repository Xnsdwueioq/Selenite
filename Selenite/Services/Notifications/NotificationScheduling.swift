//
//  NotificationScheduling.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/27/26.
//

import FocusCore

protocol NotificationScheduling {
  func reschedule(to boundaries: [PhaseBoundary]) async
  func cancelAll() async
}
