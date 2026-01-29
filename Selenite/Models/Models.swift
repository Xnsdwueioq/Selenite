//
//  Models.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 28.01.2026.
//

import Foundation
import SwiftData


enum SessionType: String, Codable {
  case active
  case solid
  case fragmented
}

@Model
final class SessionInterval {
  var startTime: Date
  var endTime: Date?
  var calendarEventID: String?
  
  var duration: TimeInterval {
    startTime.distance(to: endTime ?? Date())
  }
  
  init(startTime: Date = Date(), endTime: Date? = nil, calendarEventID: String? = nil) {
    self.startTime = startTime
    self.endTime = endTime
    self.calendarEventID = calendarEventID
  }
}

@Model
final class Session {
  var title: String
  var sessionType: SessionType
  var targetDuration: TimeInterval?

  @Relationship(deleteRule: .cascade)
  var intervals: [SessionInterval]
  
  var sessionDuration: TimeInterval {
    intervals.reduce(into: 0) { totalSum, interval in
      totalSum += interval.duration
    }
  }
  var interruptionsDuration: TimeInterval {
    guard intervals.count >= 2 else { return 0 }
    let sortedIntervals = intervals.sorted(by: { $0.startTime < $1.startTime })
    
    var totalDuration: TimeInterval = 0
    for i in 0..<(sortedIntervals.count - 1) {
      guard let pauseStartTime: Date = sortedIntervals[i].endTime else { continue }
      let pauseEndTime: Date = sortedIntervals[i + 1].startTime
      totalDuration += pauseStartTime.distance(to: pauseEndTime)
    }
    
    return totalDuration
  }
  var isCompleted: Bool {
    guard targetDuration != nil else { return false }
    return sessionDuration >= targetDuration! ? true : false
  }
  
  init(title: String = "", sessionType: SessionType = SessionType.active, targetDuration: TimeInterval? = nil, intervals: [SessionInterval] = []) {
    self.title = title
    self.targetDuration = targetDuration
    self.sessionType = sessionType
    self.intervals = intervals
  }
}
