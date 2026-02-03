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
  var modelContext: ModelContext?
  
  private var activePeriod: Period?
  var periodState: PeriodState = .idle
  var periodType: PeriodType = .session
  
  init(settingsManager: SettingsManager = .shared, modelContext: ModelContext? = nil) {
    self.settingsManager = settingsManager
    self.modelContext = modelContext
  }
  
  // MARK: - Session
  
  private var currentSessionNumber = 1
  private var currentSessionIndicator: SessionIndicator = .notStart
  
  
  func increaseSessionNumber() {
    currentSessionNumber += 1
  }
  
  func decreaseSessionNumber() {
    currentSessionNumber = max(1, currentSessionNumber - 1)
  }
  
  func resetSessionNumber() {
    currentSessionNumber = 1
  }
  
  func createPeriod() {
    let breakTitle = "Перерыв"
    
    var sessionTitle: String
    var sessionDuration: Int
    
    switch periodType {
    case .session:
      sessionTitle = settingsManager.sessionTitle
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
    case .session: modelContext?.insert(newPeriod)
    default: break
    }
  }
  
  func endPeriod() {
    activePeriod = nil
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
  
  
  func startTimer() {
    createPeriod()
    appendOpenInterval()
    periodState = .active
    if periodType == .session {
      currentSessionIndicator = .didStarted
    }
    startPulse()
  }
  
  func timerEnded() {
    stopPulse()
    closeCurrentInterval()
    periodState = .idle
    if periodType == .session {
      currentSessionIndicator = .finished
    }
    
    // calculates the fragmented type
    guard let fragmentedType = activePeriod?.calculateFragmentedType else { return }
    activePeriod?.fragmentedType = fragmentedType
    
    endPeriod()
    updatePeriodType()
    
    if periodType != .session && settingsManager.areBreaksDisabled {
      skipTime()
    }
    
    switch periodType {
    case .session:
      if settingsManager.sessionAutostart { startTimer() }
    case .shortBreak, .longBreak:
      if settingsManager.breakAutostart { startTimer() }
    }
  }
  
  func updatePeriodType() {
    switch periodType {
    case .session:
      currentSessionIndicator = .finished
      periodType = nextBreakAreLong ? .longBreak : .shortBreak
      
    case .shortBreak, .longBreak:
      if periodType == .shortBreak {
        increaseBreaksCount()
        increaseSessionNumber()
      } else {
        resetBreaksCount()
        resetSessionNumber()
      }
      currentSessionIndicator = .notStart
      periodType = .session
    }
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
  
  // MARK: Skip & Return Time Logic
  func skipTime() {
    switch periodState {
    case .idle: break
    default:
      stopPulse()
      guard let period = activePeriod else { return }
      if !period.isIntervalClosed { closeCurrentInterval() }
      if periodType == .session {
        currentSessionIndicator = .finished
        period.fragmentedType = period.calculateFragmentedType
      }
      endPeriod()
    }
    periodState = .idle
    updatePeriodType()
    if periodType != .session && settingsManager.areBreaksDisabled {
      skipTime()
    }
  }
  
  func returnPeriods(returnType: ReturnType) {
    switch returnType {
    case .toOne:
      updateReturnType()
      if periodType != .session && settingsManager.areBreaksDisabled {
        returnPeriods(returnType: .toOne)
      }
      
    case .toTop:
      switch periodState {
      case .idle: break
      default:
        stopPulse()
        endPeriod()
      }
      resetBreaksCount()
      resetSessionNumber()
      periodType = .session
      currentSessionIndicator = .notStart
    }
  }
  
  func updateReturnType() {
    switch periodState {
    case .idle:
      
      switch periodType {
      case .session:
        if !(currentSessionNumber == 1 && currentSessionIndicator == .notStart) {
          periodType = .shortBreak
          currentSessionIndicator = .notStart
          decreaseBreaksCount()
          
          currentSessionIndicator = .finished
          decreaseSessionNumber()
        }
        
      case .shortBreak, .longBreak:
        periodType = .session
        currentSessionIndicator = .notStart
      }
      
      
    default:
      if let period = activePeriod {
        stopPulse()
        if !period.isIntervalClosed {
          closeCurrentInterval()
          period.fragmentedType = period.calculateFragmentedType
        }
        endPeriod()
      }
      
      
      switch periodType {
      case .session:
        currentSessionIndicator = .notStart
      case .shortBreak, .longBreak: break
      }
      
      periodState = .idle
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
  
  // MARK: Title
  func getTitle() -> String {
    let breakTitle = "Перерыв"
    let defaultTitle = "Selenite"
    
    switch periodType {
    case .session:
      if periodState != .idle {
        return activePeriod?.title ?? defaultTitle
      } else {
        return settingsManager.sessionTitle
      }
      
    case .shortBreak, .longBreak:
      return breakTitle
    }
  }
  
  func getDisableCondition() -> Bool {
    if (periodState != .idle) || (periodType != .session) {
      return true
    }
    return false
  }
  
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
    
    let visualCompensation: TimeInterval = 1
    
    let targetDuration = period.targetDuration ?? 0
    let sessionDuration = period.periodDuration
    
    let total = targetDuration - sessionDuration
    
    return max(0, total - visualCompensation).rounded(.up)
  }
  
  // MARK: Play/Pause Button
  func playButtonAction() {
    printData(with: "old data---")
    switch periodState {
    case .idle:
      startTimer()
    case .active:
      pauseTimer()
    case .paused:
      resumeTimer()
    }
    printData(with: "---new data")
  }
  
  func playButtonSystemImage() -> String {
    switch periodState {
    case .idle:
      "play.fill"
    case .active:
      "pause.fill"
    case .paused:
      "play.fill"
    }
  }
  
  // MARK: Prev/Next Buttons
  func previousButtonAction() {
    returnPeriods(returnType: .toOne)
  }
  
  func nextButtonAction() {
    // DEBUG
    printData(with: "---before skip")
    skipTime()
    printData(with: "after skip---")
    
  }
  
  // MARK: Reset Button
  func resetButtonAction() {
    returnPeriods(returnType: .toTop)
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
  
  // MARK: - Debug Module
  func printData(with message: String) {
    print(message)
    print("curr session: \(currentSessionNumber)")
    print("curr session indicator: \(currentSessionIndicator)")
    print("breakCount: \(breaksCount)")
    print("periodType: \(periodType)")
    print("periodState: \(periodState)")
  }
}
