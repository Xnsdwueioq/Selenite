//
//  String+Validation.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 13.02.2026.
//

import Foundation


extension String {
  var validTitle: String? {
    let trimmed = self
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "\n", with: " ")
      .replacingOccurrences(of: "\r", with: " ")
    
    if trimmed.isEmpty || trimmed.count > 50 {
      return nil
    }
    return trimmed
  }
}
