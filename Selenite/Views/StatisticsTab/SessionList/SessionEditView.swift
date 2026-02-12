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
  
  @State private var showAlert = false
  private let notEndedTime = "Не завершено"
  
  var body: some View {
    List {
      Section {
        VStack(alignment: .leading) {
          Text("Название")
            .foregroundStyle(.secondary)
            .font(.footnote)
          TextField(
            "Название",
            text: Binding(
              get: {
                viewModel?.draftSessionTitle ?? "Selenite"
              },
              set: { newTitle in
                viewModel?.draftSessionTitle = newTitle
              }),
            prompt: Text("Selenite")
          )
        }
        
        VStack(alignment: .leading) {
          Text("Длительность сессии")
            .foregroundStyle(.secondary)
            .font(.footnote)
          Text(viewModel?.getFormattedDuration() ?? "")
        }
      }
      
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
          if viewModel?.saveChanges() ?? false {
            dismiss()
          } else {
            showAlert = true
          }
        }
        .buttonStyle(.glassProminent)
      }
    }
    .onAppear {
      viewModel = SessionEditViewModel(modelContext: modelContext, session: session)
    }
    .alert(
      "Некорректное название сессии",
      isPresented: $showAlert,
      actions: {
        Button("Ок", role: .cancel) {
          showAlert = false
        }
        Button("Сбросить заголовок", role: .destructive) {
          viewModel?.resetTitle()
        }
      },
      message: {
        Text("Название не может состоять только из пробелов или содержать больше 50 символов")
      }
    )
    .navigationTitle("Редактирование")
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
