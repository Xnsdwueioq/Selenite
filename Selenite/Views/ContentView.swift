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
    NavigationStack {
      List {
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
        .onDelete(perform: deleteSessions)
      }
      .overlay {
        if sessions.isEmpty {
          ContentUnavailableView("Нет сессий", systemImage: "hourglass.bottomhalf.filled", description: Text("Начните свою первую сессию фокусировки").foregroundStyle(.secondary))
        }
      }
      .navigationTitle("Selenite")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: addSession) {
            Label("Добавить", systemImage: "plus")
          }
        }
      }
    }
  }
  
  private func addSession() {
    let newSession = Session(title: "Тестовая сессия \(sessions.count + 1)")
    let firstInterval = SessionInterval(startTime: Date())
    newSession.intervals.append(firstInterval)
    
    modelContext.insert(newSession)
  }
  
  private func deleteSessions(offsets: IndexSet) {
    for index in offsets {
      modelContext.delete(sessions[index])
    }
  }
  
}

#Preview {
  ContentView()
    .modelContainer(for: [Session.self, SessionInterval.self])
}
