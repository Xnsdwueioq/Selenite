//
//  SnapshotWriting.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/27/26.
//

import FocusCore

protocol SnapshotWriting {
  func write(_ state: TimerState) async
}
