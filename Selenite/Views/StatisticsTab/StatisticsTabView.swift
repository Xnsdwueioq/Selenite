//
//  StatisticsTabView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct StatisticsTabView: View {
  var body: some View {
    
  }
}

#Preview {
  StatisticsTabView()
    .modelContainer(for: [Session.self, SessionInterval.self])
    .environment(TimerManager())
    .tint(.purple.mix(with: .red, by: 0.6))
}
