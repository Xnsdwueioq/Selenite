//
//  TimerManager.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class TimerManager {
  // ===============LOGIC===============
  var activeSession: Session?
  var selectedDuration: TimeInterval? = 10 // потом планируется забирать из настроек пользователя
  var isSolid: Bool {
    if activeSession?.targetDuration != nil && activeSession?.intervals.count == 1 {
      true
    } else {
      false
    }
  }
    
  // initialize new session with `targetDuration` as `selectedDuration`
  // append to it `TimeInterval` instance
  // insert with modelContext and call `startPulse`
  func startSession(modelContext: ModelContext) {
    let newSession = Session(title: "Selenite", targetDuration: selectedDuration)
    let firstInterval = SessionInterval(startTime: Date())
    
    newSession.intervals.append(firstInterval)
    activeSession = newSession

    modelContext.insert(newSession)
    
    startPulse()
  }
  
  // call `stopPulse` and set `sessionType` to `activeSession`
  func endSession() {
    stopPulse()
    activeSession?.sessionType = isSolid ? .solid : .fragmented
  }
  
  private var timer: Timer?
  var pulse: Bool = false
  
  // start pulsing and add new interval with current start time
  private func resume() {
    let nextInterval = SessionInterval(startTime: Date())
    activeSession?.intervals.append(nextInterval)
    startPulse()
  }
  
  // stop pulsing and if last interval continues, end its with current date
  private func pause() {
    if let lastInterval = activeSession?.intervals.last, lastInterval.endTime == nil {
      lastInterval.endTime = Date()
    }
    stopPulse()
  }
  
  // if there is `activeSession`, initialize `timer`, which pulsing every second
  // call `endSession` if `activeSession` is completed
  private func startPulse() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
      guard let self = self, let session = self.activeSession else { return }
      self.pulse.toggle()
      if session.isCompleted { self.endSession() }
    })
  }
  
  // invalidate and dissolve `timer`
  private func stopPulse() {
    timer?.invalidate()
    timer = nil
  }
  
  // ===============VIEW===============
  func displayCount() -> String {
    remainingTimeString()
  }
  
  private func remainingSeconds() -> TimeInterval {
    guard let session = activeSession else { return 0 }
    
    let target = session.targetDuration ?? 0
    let current = session.sessionDuration
    
    return max(target - current, 0)
  }
  
  private func remainingTimeString() -> String {
    let totalSeconds: Int = Int(remainingSeconds().rounded(.up))
    
    let seconds = totalSeconds % 60
    let minutes = totalSeconds / 60
    
    return String(format: "%02d:%02d", minutes, seconds)
  }
}
