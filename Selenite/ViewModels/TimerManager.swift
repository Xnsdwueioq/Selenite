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
  var activeSession: Session?
  
  var pulse: Bool = false
  
  private var timer: Timer?
  
  func startNewSession(modelContext: ModelContext) {
    let newSession = Session(title: "Selenite")
    let firstInterval = SessionInterval(startTime: Date())
    
    newSession.intervals.append(firstInterval)
    activeSession = newSession

    modelContext.insert(newSession)
    
    startPulse()
  }
  
  func resume() {
    let nextInterval = SessionInterval(startTime: Date())
    activeSession?.intervals.append(nextInterval)
    startPulse()
  }
  
  func pause() {
    if let lastInterval = activeSession?.intervals.last, lastInterval.endTime == nil {
      lastInterval.endTime = Date()
    }
    stopPulse()
  }
  
  private func startPulse() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
      self?.pulse.toggle()
    })
  }
  
  private func stopPulse() {
    timer?.invalidate()
    timer = nil
  }
}
