//
//  ListRowView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 13.02.2026.
//

import SwiftUI

struct ListRowView: View {
  let session: Period
  
  var body: some View {
    NavigationLink(value: StatisticsScreen.sessionEdit(session: session)) {
      HStack {
        Text(session.title)
        Spacer()
        Text(session.startDate.formatted())
          .foregroundStyle(.secondary)
      }
    }
  }
}
