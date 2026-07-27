//
//  SharedSnapshotStore.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/27/26.
//

import Foundation
import FocusCore
import OSLog

struct SharedSnapshotStore: SnapshotWriting, SnapshotReading {
  var snapshotURL: URL? {
    FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: AppIdentifiers.appGroup)?
      .appendingPathComponent("snapshot.json")
  }
  
  func write(_ state: TimerState) async {
    guard let snapshotURL else {
      Logger.sharedSnapshotStore.error("Unable to write snapshot. The snapshotURL could not be found")
      return
    }
    
    do {
      let data = try JSONEncoder().encode(state)
      try data.write(to: snapshotURL, options: .atomic)
    } catch {
      Logger.sharedSnapshotStore.error("Unable to write snapshot: \(error.localizedDescription)")
    }
  }
  
  func read() -> TimerState? {
    guard let snapshotURL else {
      Logger.sharedSnapshotStore.error("Unable to read snapshot. The snapshotURL could not be found")
      return nil
    }
    guard let data = try? Data(contentsOf: snapshotURL) else {
      Logger.sharedSnapshotStore.debug("Unable to read snapshot. The data in the snapshotURL could not be found.")
      return nil
    }
    
    do {
      let timerState = try JSONDecoder().decode(TimerState.self, from: data)
      return timerState
    } catch {
      Logger.sharedSnapshotStore.error("Unable to read snapshot. Decoding failed (The model may have changed): \(error.localizedDescription).")
    }
    return nil
  }
}
