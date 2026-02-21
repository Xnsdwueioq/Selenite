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
      
      ForEach(viewModel.draftIntervals.indices, id: \.self) { index in
        Section {
          VStack(alignment: .leading) {
            HStack(spacing: 4) {
              DatePicker(
                selection: $viewModel.draftIntervals[index].startTime,
                in: viewModel.getDatePickerRange(index: index, start: true),
                displayedComponents: [.date, .hourAndMinute]
              ) { EmptyView() }
              SecondsPickerView(date: $viewModel.draftIntervals[index].startTime, secondsRange: viewModel.getSecondsPickerRange(index: index, start: true))
            }
          }
          
          VStack(alignment: .leading) {
            if let _ = viewModel.draftIntervals[index].endTime {
              let endTimeBinding = Binding(
                get: { viewModel.draftIntervals[index].endTime ?? Date() },
                set: { viewModel.draftIntervals[index].endTime = $0 }
              )
              HStack(spacing: 4) {
                DatePicker(
                  selection: endTimeBinding,
                  in: viewModel.getDatePickerRange(index: index, start: false),
                  displayedComponents: [.date, .hourAndMinute]
                ) { EmptyView() }
                SecondsPickerView(date: endTimeBinding, secondsRange: viewModel.getSecondsPickerRange(index: index, start: false))
              }
            } else {
               Text(notEndedTime)
             }
          }
        }
        .listRowSeparator(.hidden)
      }
      .onAppear {
        viewModel.printDraftIntervals()
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
