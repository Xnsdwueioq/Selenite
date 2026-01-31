//
//  SessionProgressView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 01.02.2026.
//

import SwiftUI

struct SessionProgressView: View {
  let total: Int
  let current: Int
  let workSessionState: WorkSessionState
  
  private let sideLength: CGFloat = 25
  
  var body: some View {
    HStack {
      ForEach(1...total, id: \.self) { index in
        RoundedRectangle(cornerRadius: 5)
          .frame(width: sideLength, height: sideLength)
          .foregroundStyle(color(for: index))
      }
    }
  }
  
  func color(for index: Int) -> Color {
    if index < current { return .purple }
    else if (index == current) && (workSessionState == .finished) { return .purple }
    else if (index == current) && (workSessionState == .didStarted) { return .purple.opacity(0.4) }
    else { return .gray.opacity(0.2) }
  }
}

#Preview {
  SessionProgressView(total: 5, current: 3, workSessionState: .didStarted)
}
