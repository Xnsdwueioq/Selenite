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
  
  @State private var activeAlert: ActiveAlert?
  
  var body: some View {
    List {
      Section {
        SessionTitleView(viewModel: viewModel)
        SessionDurationView(viewModel: viewModel)
      }
      
      SessionIntervalsView(viewModelValue: viewModel)
    }
    .navigationTitle("Редактирование")
    .toolbar {
      // Back button
      ToolbarItem(placement: .topBarLeading) {
        Button("Назад", systemImage: "chevron.left") {
          if !(viewModel?.isChangesSaved ?? true) {
            activeAlert = .backWithNoSave
          } else {
            dismiss()
          }
        }
      }
      
      // Delete session button
      ToolbarItem(placement: .topBarTrailing) {
        Button("Удалить", systemImage: "trash", role: .destructive) {
          activeAlert = .deleteSession
        }
      }
      
      // Save session button
      ToolbarItem(placement: .topBarTrailing) {
        Button("Сохранить", systemImage: "checkmark") {
          if viewModel?.saveChanges() ?? false {
            dismiss()
          } else {
            activeAlert = .incorrectTitle
          }
        }
        .buttonStyle(.glassProminent)
      }
    }
    .navigationBarBackButtonHidden()
    .interactiveDismissDisabled()
    .onAppear {
      viewModel = SessionEditViewModel(modelContext: modelContext, session: session)
    }
    .alert(
      activeAlert?.alertTitle ?? "",
      isPresented: Binding(
        get: { activeAlert != nil },
        set: { if !$0 { activeAlert = nil } }
      ),
      presenting: activeAlert
    ) { alert in
      switch alert {
      case .incorrectTitle:
        Button("Вернуть заголовок", role: .destructive) {
          viewModel?.resetTitle()
        }
        Button("Отмена", role: .cancel) { }
        
      case .deleteSession:
        Button("Подтвердить", role: .destructive) {
          viewModel?.deleteSession()
          dismiss()
        }
        Button("Отмена", role: .cancel) { }
        
      case .backWithNoSave:
        Button("Сохранить", role: .confirm) {
          let _ = viewModel?.saveChanges()
          dismiss()
        }
        Button("Не сохранять", role: .destructive) {
          dismiss()
        }
        Button("Отмена", role: .cancel) { }
      }
    } message: { alert in
      if let message = alert.alertMessage {
        Text(message)
      }
    }
  }
  
  enum ActiveAlert {
    case incorrectTitle
    case deleteSession
    case backWithNoSave
    
    var alertTitle: String {
      switch self {
      case .incorrectTitle:
        return "Некорректное название сессии"
      case .deleteSession:
        return "Удалить сессию?"
      case .backWithNoSave:
        return "Сохранить данные перед выходом?"
      }
    }
    
    var alertMessage: String? {
      switch self {
      case .incorrectTitle:
        return "Название не может состоять только из пробелов или содержать больше 50 символов"
      default:
        return nil
      }
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
