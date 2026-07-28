//
//  AppFlags.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import Foundation

nonisolated struct AppFlags {
  private let store: UserDefaults

  init(store: UserDefaults = UserDefaults(suiteName: AppIdentifiers.appGroup) ?? .standard) {
    self.store = store
  }

  var didExplainNotifications: Bool {
    get { store.bool(forKey: #function) }
    nonmutating set { store.set(newValue, forKey: #function) }
  }
}
