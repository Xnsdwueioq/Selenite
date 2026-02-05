//
//  SessionListViewModel.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 05.02.2026.
//

import Foundation
import SwiftData

@Observable
final class SessionListViewModel {
  private var modelContext: ModelContext
  private var sessions: [Period]
  
  init(modelContext: ModelContext, sessions: [Period] = []) {
    self.modelContext = modelContext
    self.sessions = sessions
  }
}
