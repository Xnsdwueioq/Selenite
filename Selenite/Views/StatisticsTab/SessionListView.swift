//
//  SessionListView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 05.02.2026.
//

import SwiftUI
import SwiftData

struct SessionListView: View {
  @State private var viewModel = SessionListViewModel(modelContext:)
  
  var body: some View {
    List {
      Text("Test")
    }
  }
}

#Preview {
  let container: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try! ModelContainer(for: Period.self, PeriodInterval.self, configurations: config)
  }()
  
  SessionListView()
    .modelContainer(container)
    .tint(.purpleBrand)
}
