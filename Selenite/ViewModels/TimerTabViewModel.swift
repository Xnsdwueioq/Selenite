//
//  TimerTabViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 03.02.2026.
//

import Foundation
import UIKit

@Observable
final class TimerTabViewModel {
  private let settingsManager: SettingsManager
  
  init(settingsManager: SettingsManager = .shared) {
    self.settingsManager = settingsManager
  }
  
  // MARK: - Drag Gesture Processing
  
  private var processedDistance: CGFloat = 0
  private var lastHeight: CGFloat = 0
  private let sensitivity: CGFloat = 20
  
  func handleDragGesture(with translationHeight: CGFloat, periodType: PeriodType) {
    let oppositeTranslationHeight = -translationHeight
    let delta = oppositeTranslationHeight - lastHeight
    
    processedDistance += delta
    
    if abs(processedDistance) >= sensitivity {
      updateDuration(by: Int(processedDistance / sensitivity), periodType: periodType)
      processedDistance = 0
    }
    lastHeight = oppositeTranslationHeight
  }
  
  private func updateDuration(by minutes: Int, periodType: PeriodType) {
    switch periodType {
    case .session:
      settingsManager.sessionDuration = settingsManager.validation(of: settingsManager.sessionDuration + minutes)
    case .shortBreak:
      settingsManager.shortBreakDuration = settingsManager.validation(of: settingsManager.shortBreakDuration + minutes)
    case .longBreak:
      settingsManager.longBreakDuration = settingsManager.validation(of: settingsManager.longBreakDuration + minutes)
    }
    let generator = UIImpactFeedbackGenerator(style: .soft)
    generator.impactOccurred()
  }
  
  func endDragGesture() {
    processedDistance = 0
    lastHeight = 0
  }
}
