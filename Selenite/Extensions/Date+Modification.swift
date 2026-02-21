//
//  Date+Modification.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 21.02.2026.
//

import Foundation

extension Date {
  func setSeconds(seconds: Int) -> Date {
    let calendar = Calendar.current
    
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
    components.second = seconds
    return calendar.date(from: components) ?? self
  }
}
