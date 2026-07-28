//
//  Phase+DisplayName.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

import FocusCore
import Foundation

extension Phase {
  var displayName: String {
    switch self {
    case .work:
      String(localized: "phase.work", defaultValue: "сессия")
    case .shortBreak:
      String(localized: "phase.shortBreak", defaultValue: "короткий перерыв")
    case .longBreak:
      String(localized: "phase.longBreak", defaultValue: "длинный перерыв")
    case .idle:
      String(localized: "phase.idle", defaultValue: "ожидание")
    case .awaiting:
      String(localized: "phase.awaiting", defaultValue: "готовность")
    case .finished:
      String(localized: "phase.finished", defaultValue: "завершение")
    }
  }
}
