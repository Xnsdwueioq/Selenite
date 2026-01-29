//
//  ContentView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 28.01.2026.
//

import SwiftUI
import SwiftData

struct SessionsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query var sessions: [Session]
  var body: some View {
    Group {
      ForEach(sessions) { session in
        VStack(alignment: .leading) {
          Text(session.title.isEmpty ? "Без названия" : session.title)
            .font(.headline)
          Text(session.sessionType.rawValue)
          
          HStack {
            Text("Интервалов: \(session.intervals.count)")
            Spacer()
            Text(String(format: "Событие %.2f", session.sessionDuration))
              .foregroundStyle(.secondary)
            Text(String(format: "Перерывы %.2f", session.interruptionsDuration))
              .foregroundStyle(.secondary)
          }
          .font(.caption)
        }
      }
    }
  }
}
