//
//  CalendarSyncContainer.swift
//  Drafts
//
//  Created by Eyhciurmrn Zmpodackrl on 04.04.2026.
//

import SwiftUI
import EventKit

struct CalendarSyncContainer: View {
  @Bindable var viewModel: CalendarSyncViewModel
  
  var body: some View {
    CalendarSyncView(viewModel: viewModel)
      .onAppear {
        viewModel.checkAuthorisationStatus()
      }
      .animation(.snappy, value: viewModel.isSynchronizeOn)
      .sheet(
        isPresented: $viewModel.isCalendarSelected,
        onDismiss: viewModel.onDismissCalendarSelected
      ) {
        CalendarsSheetView(viewModel: viewModel)
          .presentationDragIndicator(.visible)
          .presentationDetents([.medium, .large])
          .sheet(
            isPresented: $viewModel.isCalendarCreated,
            onDismiss: viewModel.onDismissCalendarCreated
          ) {
            CalendarCreationSheetView(
              newCalendarTitle: $viewModel.newCalendarTitle,
              newCalendarColor: $viewModel.newCalendarColor,
              creationCalendarAction: viewModel.creationCalendarAction,
              isNewCalendarTitleValidate: viewModel.isNewCalendarTitleValidate
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large])
          }
      }
      .alert("Нет доступа к календарю",
             isPresented: $viewModel.isAlertPresent,
             actions: {
        Button("Перейти в настройки", role: .confirm) {
          Task {
            await viewModel.openSettings()
          }
        }
        Button("Ок", role: .close) { }
      },
             message: { Text("Перейдите в настройки и разрешите полный доступ") }
      )
      .alert("Календарь не выбран",
             isPresented: $viewModel.isCalendarNilPresent,
             actions: {
        Button("Выбрать календарь", role: .cancel) { viewModel.openCalendarSelectionSheet() }
        Button("Выключить синхронизацию", role: .destructive) { viewModel.isSynchronizeOn = false }
      },
             message: { Text("Выберите новый календарь для возможности синхронизации с Apple Calendar") }
      )
  }
}
