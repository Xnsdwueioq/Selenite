//
//  TimerManager.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import Foundation
import SwiftData


enum PeriodState {
  case idle
  case active
  case paused
  case finished
}

enum PeriodType {
  case session
  case shortBreak
  case longBreak
}

enum SessionIndicator {
  case notStart
  case didStarted
  case finished
}

enum ReturnType {
  case toOne
  case toTop
}

@Observable
final class TimerManager {
  private let settingsManager: SettingsManager
  
  private var activePeriod: Period?
  var periodState: PeriodState = .idle
  private var periodType: PeriodType = .session
  
  init(settingsManager: SettingsManager = .shared) {
    self.settingsManager = settingsManager
  }
  
  // MARK: - Session
  
  private var currentSessionNumber = 0
  private var currentSessionIndicator: SessionIndicator = .notStart
  
  
  func increaseSessionCount() {
    currentSessionNumber += 1
  }
  
  func decreaseSessionCount() {
    currentSessionNumber = max(0, currentSessionNumber - 1)
  }
  
  func resetSessionCount() {
    currentSessionNumber = 0
  }
  
  func createPeriod(modelContext: ModelContext) {
    let breakTitle = "Перерыв"
    
    var sessionTitle: String
    var sessionDuration: Int
    
    switch periodType {
    case .session:
      sessionTitle = "Selenite"
      sessionDuration = settingsManager.sessionDuration
    case .shortBreak:
      sessionTitle = breakTitle
      sessionDuration = settingsManager.shortBreakDuration
    case .longBreak:
      sessionTitle = breakTitle
      sessionDuration = settingsManager.longBreakDuration
    }
    
    let newPeriod = Period(title: sessionTitle, targetDuration: TimeInterval(sessionDuration))
    activePeriod = newPeriod
  
    switch periodType {
    case .session: modelContext.insert(newPeriod)
    default: break
    }
  }
  
  func endPeriod() {
    activePeriod = nil
    periodState = .idle
  }
  
  // MARK: - Breaks Logic
  
  private var breaksCount: Int = 0
  
  private var nextBreakAreLong: Bool {
    return (breaksCount + 1) == settingsManager.sessionCount
  }
  
  func increaseBreaksCount() {
    breaksCount += 1
  }
  
  func decreaseBreaksCount() {
    breaksCount = max(0, breaksCount - 1)
  }
  
  func resetBreaksCount() {
    breaksCount = 0
  }
  
  func updatePeriodTypeAfterTimerEnding() {
    switch periodType {
    case .session:
      periodType = nextBreakAreLong ? .longBreak : .shortBreak
      
    case .shortBreak, .longBreak:
      if periodType == .shortBreak {
        increaseBreaksCount()
      } else {
        resetBreaksCount()
        resetSessionCount()
      }
      periodType = .session
    }
  }
  
//  func cancelToPreviousUpdateType() {
//    switch periodType {
//    case .session:
//      decreaseBreaksCount()
//      decreaseSessionCount()
//      if currentSessionNumber > 0 { periodType = .shortBreak }
//    case .shortBreak:
//      periodType = .session
//    case .longBreak:
//      periodType = .session
//    }
//  }
  
  // MARK: - Interval
  
  func appendOpenInterval() {
    activePeriod?.intervals.append(PeriodInterval(startTime: Date()))
  }
  
  func closeCurrentInterval() {
    activePeriod?.intervals.last?.endTime = Date()
  }
  
  // MARK: - Timer Controls
  
  var pulse: Bool = false
  
  private var timer: Timer?
  
  
  func startTimer(modelContext: ModelContext) {
    createPeriod(modelContext: modelContext)
    appendOpenInterval()
    periodState = .active
    if periodType == .session {
      currentSessionIndicator = .didStarted
      increaseSessionCount()
    }
    startPulse()
  }
  
  func timerEnded() {
    guard periodState != .finished else { return } // TODO: попробывать убрать
    
    stopPulse()
    closeCurrentInterval()
    periodState = .finished
    
    // calculates the fragmented type
    guard let fragmentedType = activePeriod?.calculateFragmentedType else { return }
    activePeriod?.fragmentedType = fragmentedType
    
    // after 1 sec ends the session, change indicator and update period type
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
      self?.endPeriod()
      self?.periodState = .idle
      if self?.periodType == .session {
        self?.currentSessionIndicator = .finished
      }
      self?.updatePeriodTypeAfterTimerEnding()
    })
  }
  
  
  func resumeTimer() {
    appendOpenInterval()
    periodState = .active
    startPulse()
  }
  
  func pauseTimer() {
    closeCurrentInterval()
    periodState = .paused
    stopPulse()
  }
  
  // MARK: Skip Time Logic
  func skipTime() {
    switch periodState {
    case .idle:
      if periodType == .session {
        increaseSessionCount()
        currentSessionIndicator = .finished
      }
      
    default:
      guard let period = activePeriod else { return }
      
      if periodType == .session {
        if !period.isIntervalClosed { closeCurrentInterval() }
        currentSessionIndicator = .finished
        period.fragmentedType = period.calculateFragmentedType
      }
      stopPulse()
      endPeriod()
    }
    
    updatePeriodTypeAfterTimerEnding()
  }
  
  
  // TODO: Return Logic
  func returnPeriods(returnType: ReturnType, modelContext: ModelContext) {
    switch returnType {
    case .toOne: break
    case .toTop:
      switch periodState {
      case .idle: break
      default:
        guard let period = activePeriod else { return }
        modelContext.delete(period)
        stopPulse()
        endPeriod()
      }
      resetBreaksCount()
      resetSessionCount()
      periodType = .session
      currentSessionIndicator = .notStart
    }
  }
  
  // MARK: - Pulsing Control
  
  func startPulse() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
      guard let self = self, let isCompleted = activePeriod?.isCompleted else { return }
      
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
  
  // MARK: - View Logic
  
  // MARK: Time Formatting
  private static let timeFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter
  }()
  
  func remainingTime() -> String {
    let time = remainingTimeInterval()
    
    return Self.timeFormatter.string(from: time) ?? "00:00"
  }
  
  func remainingTimeInterval() -> TimeInterval {
    guard let period = activePeriod else {
      var remainingTime: Int
      switch periodType {
      case .session:
        remainingTime = settingsManager.sessionDuration
      case .shortBreak:
        remainingTime = settingsManager.shortBreakDuration
      case .longBreak:
        remainingTime = settingsManager.longBreakDuration
      }
      return TimeInterval(remainingTime)
    }
    
    let targetDuration = period.targetDuration ?? 0
    let sessionDuration = period.periodDuration
    
    let total = targetDuration - sessionDuration
    
    return max(0, total).rounded(.up)
  }
  
  // MARK: Play/Pause Button
  func playButtonAction(modelContext: ModelContext) {
    switch periodState {
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
    switch periodState {
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
  
  // MARK: Prev/Next Buttons
  func previousButtonAction(modelContext: ModelContext) {
    returnPeriods(returnType: .toOne, modelContext: modelContext)
  }
  
  func nextButtonAction() {
    skipTime()
  }
  
  // MARK: Reset Button
  func resetButtonAction(modelContext: ModelContext) {
    returnPeriods(returnType: .toTop, modelContext: modelContext)
  }
  
  // MARK: Session Indicators
  func getSessionsTotalNumber() -> Int {
    return settingsManager.sessionCount
  }
  
  func getCurrentSessionNumber() -> Int {
    return currentSessionNumber
  }
  
  func getCurrentSessionIndicator() -> SessionIndicator {
    return currentSessionIndicator
  }
}
