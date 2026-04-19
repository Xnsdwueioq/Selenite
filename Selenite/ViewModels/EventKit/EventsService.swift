//
//  EventsService.swift
//  Drafts
//
//  Created by Eyhciurmrn Zmpodackrl on 04.04.2026.
//


import Foundation
import EventKit

@Observable
final class EventsService {
  let eventStore: EKEventStore
  
  init(eventStore: EKEventStore) {
    self.eventStore = eventStore
  }
  
  private func addEvent(event name: String, start startDate: Date, end endDate: Date, calendar calendarItem: CalendarItem) -> String? {
    guard let calendar = eventStore.calendar(withIdentifier: calendarItem.id) else {
      print("The event wasn not added. Could not find EKCalendar by identifier from CalendarItem")
      return nil
    }
    let event = EKEvent(eventStore: self.eventStore)
    event.title = name
    event.startDate = startDate
    event.endDate = endDate
    event.calendar = calendar
    do {
      try self.eventStore.save(event, span: .thisEvent)
      return event.eventIdentifier
    } catch {
      print("Save Error: \(error.localizedDescription)")
    }
    return nil
  }
  
  func addPeriod(calendar: CalendarItem, title: String, period: Period) {
    for interval in period.intervals {
      guard let endDate = interval.endTime else { return }
      let startDate = period.startDate
      
      if let eventID = addEvent(event: title, start: startDate, end: endDate, calendar: calendar) {
        interval.calendarEventID = eventID
      }
    }
  }
}
