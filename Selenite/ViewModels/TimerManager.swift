//
//  TimerManager.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import Foundation
import SwiftData
import SwiftUI

enum TimerState {
  case idle
  case active
  case paused
  case finished
}

@Observable
final class TimerManager {
  private let settingsManager: SettingsManager
  
  var state: TimerState = .idle
  var activeSession: Session?
  
  init(settingsManager: SettingsManager = .shared) {
    self.settingsManager = settingsManager
  }
  
  
  private static let timeFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter
  }()
  
  // MARK: - Controls
  
  func playButton(modelContext: ModelContext) {
    switch state {
    case .idle:
      startTimer(modelContext: modelContext)
    case .active:
      pauseTimer()
    case .paused:
      resumeTimer()
    case .finished:
      print("finished")
    }
  }
  
  // MARK: - State Variables
  
  private var isCompleted: Bool? {
    guard let session = activeSession, let target = session.targetDuration else { return nil }
    
    let total = session.intervals.reduce(into: 0) { total, interval in
      total += interval.duration
    }
    return total >= target
  }
  
  private var calculateSessionType: SessionType? {
    guard let session = activeSession else { return nil }
    
    switch session.intervals.count {
    case 1: return SessionType.solid
    default: return SessionType.fragmented
    }
  }
  
  // MARK: - Timer Control
  
  var pulse: Bool = false
  
  private var timer: Timer?
  
  func startTimer(modelContext: ModelContext) {
    createSession(modelContext: modelContext)
    appendOpenInterval()
    state = .active
    startPulse()
  }
  
  func timerEnded() {
    guard state != .finished else { return }
    
    stopPulse()
    closeCurrentInterval()
    state = .finished
    
    guard let type = calculateSessionType else { return }
    activeSession?.sessionType = type
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
      self?.endSession()
      self?.state = .idle
    })
  }
  
  
  func resumeTimer() {
    appendOpenInterval()
    state = .active
    startPulse()
  }
  
  func pauseTimer() {
    closeCurrentInterval()
    state = .paused
    stopPulse()
  }
  
  // MARK: - Session & Intervals
  
  func createSession(modelContext: ModelContext) {
    let newSession = Session(title: "Selenite", sessionType: .active, targetDuration: TimeInterval(settingsManager.sessionDuration))
    activeSession = newSession
    
    modelContext.insert(newSession)
  }
  
  func endSession() {
    activeSession = nil
  }
  
  func appendOpenInterval() {
    activeSession?.intervals.append(SessionInterval(startTime: Date()))
  }
  
  func closeCurrentInterval() {
    activeSession?.intervals.last?.endTime = Date()
  }
  
  // MARK: - Pulsing Control
  
  func startPulse() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
      guard let self = self, let isCompleted = isCompleted else { return }
      
      // DEBUG
      print("---PULSE---")
      for interval in activeSession?.intervals ?? [] {
        print(interval.startTime, interval.endTime ?? "nil")
      }
      
      self.pulse.toggle()
      
      if isCompleted {
        timerEnded()
      }
    })
  }
  
  func stopPulse() {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: - View
  
  func remainingTime() -> String {
    let time = remainingTimeInterval()
    
    return Self.timeFormatter.string(from: time) ?? "00:00"
  }
  
  func remainingTimeInterval() -> TimeInterval {
    guard let session = activeSession else { return TimeInterval(settingsManager.sessionDuration) }
    
    let targetDuration = session.targetDuration ?? 0
    let sessionDuration = session.sessionDuration
    
    let total = targetDuration - sessionDuration
    
    return max(0, total).rounded(.up)
  }
}
