//
//  ContentView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 28.01.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
            Text("\(session.sessionDuration) секунд")
              .foregroundStyle(.secondary)
          }
          .font(.caption)
        }
      }
    }
    .overlay {
      if sessions.isEmpty {
        ContentUnavailableView("Нет сессий", systemImage: "hourglass.bottomhalf.filled", description: Text("Начните свою первую сессию фокусировки").foregroundStyle(.secondary))
      }
    }
  }
}
