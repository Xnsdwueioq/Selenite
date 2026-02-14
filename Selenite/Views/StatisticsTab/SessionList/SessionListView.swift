//
//  SessionListView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 05.02.2026.
//

import SwiftUI
import SwiftData

struct SessionListView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var viewModel: SessionListViewModel?
  
  var body: some View {
    if (viewModel?.sessions.isEmpty ?? true) {
      ContentUnavailableView("Нет записанных сессий", systemImage: "tray.fill", description: Text("Чтобы начать свою первую сессию запустите таймер"))
    }
    List {
      ForEach(viewModel?.groupedSessions ?? []) { group in
        Section(content: {
          ForEach(group.sessions) { session in
            ListRowView(session: session)
          }
        }, header: {
          Text(group.id.formattedSectionTitle)
        })
      }
    }
    .navigationTitle("Сессии")
    .onAppear {
      if viewModel == nil {
        viewModel = SessionListViewModel(modelContext: modelContext)
      }
      
      viewModel?.fetchAllSessions()
    }
  }
}


#Preview {
  let container: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Period.self, PeriodInterval.self, configurations: config)
    let context = container.mainContext
    
    let now = Date()
    
    // 1. Короткая сессия (10 минут)
    let session1 = Period(title: "Hi, im business informatic", startDate: now.addingTimeInterval(-3600))
    let interval1 = PeriodInterval(
      startTime: now.addingTimeInterval(-3600),
      endTime: now.addingTimeInterval(-3000)
    )
    session1.intervals = [interval1]
    session1.fragmentedType = session1.calculateFragmentedType
    
    // 2. Прерванная сессия (два интервала по 15 минут с перерывом)
    let session2 = Period(title: "Daniil Samuhin", startDate: now.addingTimeInterval(-7200))
    let interval2a = PeriodInterval(
      startTime: now.addingTimeInterval(-7200),
      endTime: now.addingTimeInterval(-6300)
    )
    let interval2b = PeriodInterval(
      startTime: now.addingTimeInterval(-5400),
      endTime: now.addingTimeInterval(-4500)
    )
    session2.intervals = [interval2a, interval2b]
    session2.fragmentedType = session2.calculateFragmentedType
    
    // 3. Сессия без названия (проверка заглушки)
    let session3 = Period(title: "Glad to see u", startDate: now.addingTimeInterval(-10800))
    let interval3 = PeriodInterval(
      startTime: now.addingTimeInterval(-10800),
      endTime: now.addingTimeInterval(-9000)
    )
    session3.intervals = [interval3]
    session3.fragmentedType = session3.calculateFragmentedType
    
    let session4 = Period(title: "Glad to see u", startDate: now.addingTimeInterval(-220800))
    let interval4 = PeriodInterval(
      startTime: now.addingTimeInterval(-250800),
      endTime: now.addingTimeInterval(-50200)
    )
    session4.intervals = [interval4]
    session4.fragmentedType = session4.calculateFragmentedType
    context.insert(session4)
    // Вставляем все сессии в контекст
    context.insert(session1)
    context.insert(session2)
    context.insert(session3)
    
    return container
  }()
  
  SessionListView()
    .modelContainer(container)
    .tint(.purpleBrand)
}
