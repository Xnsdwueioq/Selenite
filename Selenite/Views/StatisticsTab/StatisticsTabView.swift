//
//  StatisticsTabView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct StatisticsTabView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(TimerManager.self) private var timerManager
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
              Text(String(format: "Событие %.2f", session.sessionDuration))
                .foregroundStyle(.secondary)
              Text(String(format: "Перерывы %.2f", session.interruptionsDuration))
                .foregroundStyle(.secondary)
            }
            .font(.caption)
          }
        }
      }
      .overlay {
        if sessions.isEmpty {
          ContentUnavailableView("Пусто", systemImage: "tray", description: Text("Нет сохраненный сессий")
            .font(.headline))
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading, content: {
          Button(action: { timerManager.clearDatabase(modelContext: modelContext) }) {
            Image(systemName: "trash")
          }
        })
      }
    }
  }
}

#Preview {
  StatisticsTabView()
    .modelContainer(for: [Session.self, SessionInterval.self])
    .environment(TimerManager(settingsManager: SettingsManager.shared))
    .tint(.purple.mix(with: .red, by: 0.6))
}
