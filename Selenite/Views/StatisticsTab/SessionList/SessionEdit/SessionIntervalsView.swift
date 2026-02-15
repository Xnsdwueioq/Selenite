//
//  SessionIntervalsView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 13.02.2026.
//

import SwiftUI

struct SessionIntervalsView: View {
  var viewModelValue: SessionEditViewModel?
  
  private let notEndedTime = "Не завершено"
  
  var body: some View {
    if let viewModelValue {
      @Bindable var viewModel = viewModelValue
      
      ForEach($viewModel.draftIntervals) { $interval in
        Section {
          VStack(alignment: .leading) {
            Text("Начало интервала")
              .foregroundStyle(.secondary)
              .font(.footnote)
            // Text(interval.startTime.formatted())
            DatePicker(
              selection: $interval.startTime,
              displayedComponents: [.date, .hourAndMinute]
            ) { EmptyView() }
          }
          
          VStack(alignment: .leading) {
            Text("Конец интервала")
              .foregroundStyle(.secondary)
              .font(.footnote)
            if let _ = interval.endTime {
              DatePicker(
                selection: Binding(
                  get: { interval.endTime ?? Date() },
                  set: { interval.endTime = $0 }
                ),
                displayedComponents: [.date, .hourAndMinute]
              ) { EmptyView() }
            } else {
               Text(notEndedTime)
             }
          }
        }
      }
    } else {
      ContentUnavailableView("Не удалось загрузить данные о сессии", systemImage: "archivebox")
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
