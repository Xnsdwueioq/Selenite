//
//  SnapshotReading.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/27/26.
//

import FocusCore

protocol SnapshotReading {
  func read() -> TimerState?
}
