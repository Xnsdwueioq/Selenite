//
//  Period.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 28.01.2026.
//

import Foundation
import SwiftData


enum FragmentedType: String, Codable {
  case undetermined
  case solid
  case fragmented
}

@Model
final class PeriodInterval {
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
final class Period {
  var title: String
  var fragmentedType: FragmentedType
  var targetDuration: TimeInterval?
  
  @Relationship(deleteRule: .cascade)
  var intervals: [PeriodInterval]
  
  var periodDuration: TimeInterval {
    intervals.reduce(into: 0) { total, interval in
      total += interval.duration
    }
  }
  var interruptionsDuration: TimeInterval {
    guard intervals.count >= 2 else { return 0 }
    let sortedIntervals = intervals.sorted(by: { $0.startTime < $1.startTime })
    
    var total: TimeInterval = 0
    for i in 0..<(sortedIntervals.count - 1) {
      guard let pauseStartTime: Date = sortedIntervals[i].endTime else { continue }
      let pauseEndTime: Date = sortedIntervals[i + 1].startTime
      total += pauseStartTime.distance(to: pauseEndTime)
    }
    
    return total
  }
  var isCompleted: Bool {
    guard let target = targetDuration else { return false }
    
    return periodDuration >= target
  }
  
  var isIntervalClosed: Bool {
    return intervals.last?.endTime != nil
  }
  var calculateFragmentedType: FragmentedType {
    switch intervals.count {
    case 1: return FragmentedType.solid
    default: return FragmentedType.fragmented
    }
  }
  
  
  init(title: String = "", fragmentedType: FragmentedType = FragmentedType.undetermined, targetDuration: TimeInterval? = nil, intervals: [PeriodInterval] = []) {
    self.title = title
    self.targetDuration = targetDuration
    self.fragmentedType = fragmentedType
    self.intervals = intervals
  }
}
