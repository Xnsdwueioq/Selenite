//
//  Period+Formatting.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 13.02.2026.
//

import Foundation


extension Period {
  var formattedDuration: String {
    let duration = Duration.seconds(periodDuration)
    return duration.formatted(
      .units(allowed: [.hours, .minutes], width: .abbreviated)
    )
  }
}
