//
//  Date+Formatting.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 13.02.2026.
//

import Foundation


extension Date {
  var smartDate: String {
    let calendar = Calendar.current
    
    let isCurrentYear = calendar.component(.year, from: self) == calendar.component(.year, from: Date())
    
    if isCurrentYear {
      return self.formatted(.dateTime.day().month(.abbreviated))
    } else {
      return self.formatted(.dateTime.day().month(.abbreviated).year())
    }
    
  }
}

extension Date {
  var formattedSectionTitle: String {
    let calendar = Calendar.current
    
    if calendar.isDateInToday(self) {
      return "Today"
    } else if calendar.isDateInYesterday(self) {
      return "Yesterday"
    } else {
      return self.smartDate
    }
  }
}

