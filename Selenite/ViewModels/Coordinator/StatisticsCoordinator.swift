//
//  StatisticsCoordinator.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 18.04.2026.
//

import Foundation

enum StatisticsScreen: Hashable {
  case sessionList
  case sessionEdit(session: Period)
}

@Observable
final class StatisticsCoordinator { }
