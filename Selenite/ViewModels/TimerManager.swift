//
//  TimerManager.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import Foundation
import SwiftData


enum TimerState {
  case idle
  case active
  case paused
  case finished
}

enum TimerType {
  case work
  case shortRest
  case longRest
}

enum WorkSessionState {
  case notStarted
  case didStarted
  case finished
}

@Observable
final class TimerManager {
  private let settingsManager: SettingsManager
  
  var state: TimerState = .idle
  var type: TimerType = .work
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
  
  // MARK: - Session State Computed Properties
  
  private var isCompleted: Bool? {
    guard let session = activeSession, let target = session.targetDuration else { return nil }
    
    let total = session.intervals.reduce(into: 0) { total, interval in
      total += interval.duration
    }
    return total >= target
  }
  
  private var calculateSessionType: SessionState? {
    guard let session = activeSession else { return nil }
    
    switch session.intervals.count {
    case 1: return SessionState.solid
    default: return SessionState.fragmented
    }
  }
  
  private var totalNumberOfSessions: Int {
    settingsManager.sessionDuration
  }
  
  // MARK: - Session
  
  private var sessionCount = 0
  private var workSessionState: WorkSessionState = .notStarted
  
  func getSessionsTotalNumber() -> Int {
    return settingsManager.sessionCount
  }
  
  func getCurrentSessionNumber() -> Int {
    return sessionCount
  }
  
  func getWorkSessionState() -> WorkSessionState {
    return workSessionState
  }
  
  func increaseSessionCount() {
    sessionCount += 1
  }
  
  func resetSessionCount() {
    sessionCount = 0
  }
  
  func createSession(modelContext: ModelContext) {
    let restTitle = "Перерыв"
    
    var sessionTitle: String
    var sessionDuration: Int
    
    switch type {
    case .work:
      sessionTitle = "Selenite"
      sessionDuration = settingsManager.sessionDuration
    case .shortRest:
      sessionTitle = restTitle
      sessionDuration = settingsManager.shortBreakDuration
    case .longRest:
      sessionTitle = restTitle
      sessionDuration = settingsManager.longBreakDuration
    }
    
    let newSession = Session(title: sessionTitle, sessionState: .active, targetDuration: TimeInterval(sessionDuration))
    activeSession = newSession
    
    switch type {
    case .work: modelContext.insert(newSession)
    default: break
    }
  }
  
  func endSession() {
    activeSession = nil
  }
  
  // MARK: - Interval
  
  func appendOpenInterval() {
    activeSession?.intervals.append(SessionInterval(startTime: Date()))
  }
  
  func closeCurrentInterval() {
    activeSession?.intervals.last?.endTime = Date()
  }
  
  // MARK: - Breaks Logic
  
  private var breaksCount: Int = 0
  
  private var nextBreakAreLong: Bool {
    return (breaksCount + 1) == settingsManager.sessionCount
  }
  
  func increaseBreaksCount() {
    breaksCount += 1
  }
  
  func resetBreaksCount() {
    breaksCount = 0
  }
  
  func updateType() {
    switch type {
    case .work:
      type = nextBreakAreLong ? .longRest : .shortRest
      
    case .shortRest, .longRest:
      if type == .shortRest {
        increaseBreaksCount()
      } else {
        resetBreaksCount()
        resetSessionCount()
      }
      type = .work
    }
  }
  
  // MARK: - Timer Control
  
  var pulse: Bool = false
  
  private var timer: Timer?
  
  func startTimer(modelContext: ModelContext) {
    createSession(modelContext: modelContext)
    appendOpenInterval()
    state = .active
    if type == .work {
      workSessionState = .didStarted
      increaseSessionCount()
    }
    startPulse()
  }
  
  func timerEnded() {
    guard state != .finished else { return }
    
    stopPulse()
    closeCurrentInterval()
    state = .finished
    
    guard let state = calculateSessionType else { return }
    activeSession?.sessionState = state
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
      self?.endSession()
      self?.state = .idle
      if self?.type == .work {
        self?.workSessionState = .finished
      }
      self?.updateType()
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
    guard let session = activeSession else {
      var remainingTime: Int
      switch type {
      case .work:
        remainingTime = settingsManager.sessionDuration
      case .shortRest:
        remainingTime = settingsManager.shortBreakDuration
      case .longRest:
        remainingTime = settingsManager.longBreakDuration
      }
      return TimeInterval(remainingTime)
    }
    
    let targetDuration = session.targetDuration ?? 0
    let sessionDuration = session.sessionDuration
    
    let total = targetDuration - sessionDuration
    
    return max(0, total).rounded(.up)
  }
  
  func playButtonAction(modelContext: ModelContext) {
    switch state {
    case .idle:
      startTimer(modelContext: modelContext)
    case .active:
      pauseTimer()
    case .paused:
      resumeTimer()
    case .finished:
      return
    }
  }
  
  func playButtonSystemImage() -> String {
    switch state {
    case .idle:
      "play.fill"
    case .active:
      "pause.fill"
    case .paused:
      "play.fill"
    case .finished:
      "pause.fill"
    }
  }
}
