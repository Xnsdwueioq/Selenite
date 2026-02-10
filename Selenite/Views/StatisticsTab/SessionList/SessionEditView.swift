//
//  SessionEditView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 06.02.2026.
//

import SwiftUI

struct SessionEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: SessionEditViewModel?
  var session: Period
  
  private let notEndedTime = "Не завершено"
  
  var body: some View {
    Form {
      Section {
        VStack(alignment: .leading) {
          Text("Название")
            .foregroundStyle(.secondary)
            .font(.footnote)
          Text(session.title.description)
        }
        
        VStack(alignment: .leading) {
          Text("Длительность сессии")
            .foregroundStyle(.secondary)
            .font(.footnote)
          Text(viewModel?.getFormattedDuration() ?? "")
        }
      }
      
      
      
      List {
        ForEach(viewModel?.getPeriodDraftIntervals() ?? []) { interval in
          VStack(alignment: .leading) {
            Text("Начало интервала")
              .foregroundStyle(.secondary)
              .font(.footnote)
            Text(interval.startTime.formatted())
          }
          
          VStack(alignment: .leading) {
            Text("Конец интервала")
              .foregroundStyle(.secondary)
              .font(.footnote)
            Text(interval.endTime?.formatted() ?? notEndedTime)
          }
        }
      }
    }
    .toolbar {
      // Delete session button
      ToolbarItem(placement: .topBarTrailing) {
        Button("Удалить", systemImage: "trash", role: .destructive) {
          viewModel?.deleteSession()
          dismiss()
        }
      }
      
      // Save session button
      ToolbarItem(placement: .topBarTrailing) {
        Button("Сохранить", systemImage: "checkmark") {
          viewModel?.saveChanges()
          dismiss()
        }
        .buttonStyle(.glassProminent)
      }
    }
    .onAppear {
      viewModel = SessionEditViewModel(modelContext: modelContext, session: session)
    }
  }
}

#Preview {
  NavigationStack {
    SessionEditView(session: Period(intervals: [
      PeriodInterval(
        startTime: Date(),
        endTime: Date().advanced(by: 120)
      ),
      PeriodInterval(startTime: Date().advanced(by: 140), endTime: Date().advanced(by: 2523))
    ]))
    .tint(.purpleBrand)
    
  }
}
