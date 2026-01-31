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
            Text(session.sessionState.rawValue)
            
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
          Button(action: {
            clearDatabase(modelContext: modelContext)
          }) {
            Image(systemName: "trash")
          }
        })
      }
    }
  }
}

@MainActor
func clearDatabase(modelContext: ModelContext) {
    let context = modelContext // ваш context
    do {
        // Удаляет все записи типа MyModel
        try context.delete(model: Session.self)
        // Если моделей несколько, нужно повторить для каждой
        // try context.delete(model: OtherModel.self)
        
        try context.save()
        print("База очищена")
    } catch {
        print("Ошибка при очистке: \(error)")
    }
}

#Preview {
  StatisticsTabView()
    .modelContainer(for: [Session.self, SessionInterval.self])
    .environment(TimerManager(settingsManager: SettingsManager.shared))
    .tint(.purple.mix(with: .red, by: 0.6))
}
