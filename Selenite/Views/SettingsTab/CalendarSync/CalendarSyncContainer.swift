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
      .alert(viewModel.alertType?.title ?? "Ошибка",
             isPresented: Binding(get: { viewModel.alertType != nil }, set: { newValue in if !newValue { viewModel.alertType = nil } }),
             presenting: viewModel.alertType,
             actions: { alertType in
        switch alertType {
        case .notAuthorized:
          Button("Перейти в настройки", role: .confirm) {
            Task {
              await viewModel.openSettings()
            }
          }
          Button("Ок", role: .close) { }
        case .nilCalendar:
          Button("Выбрать календарь", role: .cancel) { viewModel.openCalendarSelectionSheet() }
          Button("Выключить синхронизацию", role: .destructive) { viewModel.isSynchronizeOn = false }
        }
      },
             message: { alertType in
        switch alertType {
        case .notAuthorized:
          Text("Перейдите в настройки и разрешите полный доступ")
        case .nilCalendar:
          Text("Выберите новый календарь для возможности синхронизации с Apple Calendar")
        }
      }
      )
  }
}
