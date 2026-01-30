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
  var settingsManager: SettingsManager
  var activeSession: Session?
  var selectedDuration: TimeInterval? // потом планируется забирать из настроек пользователя
  var timerStatus: TimerStatus = .paused
  var isSolid: Bool {
    if activeSession?.targetDuration != nil && activeSession?.intervals.count == 1 {
      true
    } else {
      false
    }
  }
  
  init(settingsManager: SettingsManager) {
    self.settingsManager = settingsManager
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
    
    timerStatus = .running
    startPulse()
  }
  
  // call `pause` and set `sessionType` to `activeSession`
  // dissolve `activeSession`
  func endSession() {
    pause()
    timerStatus = .paused
    activeSession?.sessionType = isSolid ? .solid : .fragmented
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      self?.activeSession = nil
    }
  }
  
  private var timer: Timer?
  var pulse: Bool = false
  
  // start pulsing and add new interval with current start time
  private func resume() {
    let nextInterval = SessionInterval(startTime: Date())
    activeSession?.intervals.append(nextInterval)
    timerStatus = .running
    startPulse()
  }
  
  // stop pulsing and if last interval continues, end its with current date
  private func pause() {
    if let lastInterval = activeSession?.intervals.last, lastInterval.endTime == nil {
      lastInterval.endTime = Date()
    }
    timerStatus = .paused
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
  
  enum TimerStatus: String {
    case running, paused
  }
  
  // ===============VIEW===============
  func clearDatabase(modelContext: ModelContext) {
      if activeSession != nil {
          endSession()
      }
      try? modelContext.delete(model: Session.self)
      try? modelContext.save()
      activeSession = nil
  }
  
  func displayCount() -> String {
    remainingTimeString()
  }
  
  private func remainingSeconds() -> TimeInterval {
    guard let session = activeSession else { return selectedDuration ?? 0 }
    
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
  
  func playButtonAction(modelContext: ModelContext) {
    guard let session = activeSession else {
      startSession(modelContext: modelContext)
      return
    }
    guard !session.isCompleted else {
      return
    }
    
    switch timerStatus {
    case .running: pause()
    case .paused: resume()
    }
  }
}
