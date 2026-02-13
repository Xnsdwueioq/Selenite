//
//  SessionIntervalsView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 13.02.2026.
//

import SwiftUI

struct SessionIntervalsView: View {
  var viewModel: SessionEditViewModel?
  
  private let notEndedTime = "Не завершено"
  
  var body: some View {
    ForEach(viewModel?.getPeriodDraftIntervals() ?? []) { interval in
      VStack(alignment: .leading) {
        Text("Начало интервала")
          .foregroundStyle(.secondary)
          .font(.footnote)
        Text(interval.startTime.formatted())
      }
      
      VStack(alignment: .leading) {
        Text("Конец интервала")
          .foregroundStyle(.secondary)
          .font(.footnote)
        Text(interval.endTime?.formatted() ?? notEndedTime)
      }
    }
  }
}
