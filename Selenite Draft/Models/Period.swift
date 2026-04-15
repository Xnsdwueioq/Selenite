//
//  Period.swift
//  Selenite Draft
//
//  Created by Eyhciurmrn Zmpodackrl on 15.04.2026.
//

import Foundation
import SwiftData

/// An interval that is part of the `intervals` property of the `Period` class
@Model
final class PeriodInterval {
  var startTime: Date
  var endTime: Date?
  var calendarEventID: String?
  
  /// Returns the duration of interval
  var duration: TimeInterval {
    startTime.distance(to: endTime ?? Date())
  }
  
  /// Returns the `Bool` if `endTime` property has some value
  var isClosed: Bool {
    endTime != nil
  }
  
  init(startTime: Date = Date(), endTime: Date? = nil, calendarEventID: String? = nil) {
    self.startTime = startTime
    self.endTime = endTime
    self.calendarEventID = calendarEventID
  }
}

/// A period representing the time spent on a session
@Model
final class Period {
  var title: String
  var fragmentedType: FragmentedType = FragmentedType.undetermined
  var startDate: Date
  var targetDuration: TimeInterval
  
  @Relationship(deleteRule: .cascade)
  var intervals: [PeriodInterval]
  
  /// Returns total duration of period
  var periodDuration: TimeInterval {
    intervals.reduce(into: 0) { total, interval in
      total += interval.duration
    }
  }
  
  /// Returns duration of interruptions
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
  
  /// Returns the execution status. Result equals `True` if `periodDuration` greater than `targetDuration`
  var isCompleted: Bool {
    return periodDuration >= targetDuration
  }
  
  /// Returns the status of the period last interval's completion. Returns `True` if period hasn't intervals
  var isLastIntervalClosed: Bool {
    intervals.last?.isClosed ?? true
  }
  
  init(
    title: String = "Selenite",
    startDate: Date = Date(),
    targetDuration: TimeInterval = 1500,
    intervals: [PeriodInterval] = []
  ) {
    self.title = title
    self.targetDuration = targetDuration
    self.startDate = startDate
    self.intervals = intervals
  }
  
  /// Sets the `FragmentedType` for the `fragmentedType` property based on the number of intervals in the `intervals` property
  func calculateFragmentedType() -> Void {
    guard isLastIntervalClosed else {
      fragmentedType = .undetermined
      return
    }
    
    let intervalsCount = intervals.count
    
    if intervalsCount < 1 {
      fragmentedType = .undetermined
    } else if intervalsCount == 1 {
      fragmentedType = .solid
    } else {
      fragmentedType = .fragmented
    }
  }
  
  /// Type of period fragmentation
  enum FragmentedType: String, Codable {
    case undetermined
    case solid
    case fragmented
  }
}
