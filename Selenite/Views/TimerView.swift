//
//  TimerView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 29.01.2026.
//

import SwiftUI
import SwiftData

struct TimerView: View {
  @Environment(\.modelContext) private var modelContext: ModelContext
  @State private var timerManager = TimerManager()
  
  var body: some View {
    List {
      Section("Timer") {
        Text(timerManager.displayCount())
          .id(timerManager.pulse)
        Button("Button", systemImage: "play") {
          timerManager.playButtonAction(modelContext: modelContext)
        }
        TextField("Длительность", value: $timerManager.selectedDuration, format: .number)
          .keyboardType(.numberPad)
      }
      
      Section("Sessions") {
        ContentView()
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing, content: {
        Button(action: { }, label: {
          Image(systemName: "delete")
        })
      })
    }
  }
}

#Preview {
  TimerView()
    .modelContainer(for: [Session.self, SessionInterval.self])
}
