//
//  CalendarSyncView.swift
//  Drafts
//
//  Created by Eyhciurmrn Zmpodackrl on 04.04.2026.
//


import SwiftUI

struct CalendarSyncView: View {
  @Environment(AppSettings.self) private var appSettings
  @Bindable var viewModel: CalendarSyncViewModel
  
  var body: some View {
    @Bindable var appSettings = appSettings
    
    Section("Apple Calendar") {
      Toggle("Синхронизация с календарем", isOn: $viewModel.isSynchronizeOn.animation(.snappy))
      if viewModel.isSynchronizeOn {
        Button(action: {
          viewModel.isCalendarSelected = true
        }, label: {
          HStack(spacing: 10) {
            Text("Календарь")
            Spacer()
            Circle()
              .frame(width: 20, height: 20)
              .foregroundStyle(viewModel.selectedCalendarColorView)
            Text(viewModel.selectedCalendarTitleView)
          }
          .animation(.snappy, value: viewModel.selectedCalendarColorView)
          .animation(.snappy, value: viewModel.selectedCalendarTitleView)
        })
        .tint(.primary)
        .onChange(of: viewModel.calendarsToDisplay) {
          viewModel.onCalendarsChangedAction()
        }
      }
    }
  }
}
