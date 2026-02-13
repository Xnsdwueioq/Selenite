//
//  SessionDurationView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 12.02.2026.
//

import SwiftUI

struct SessionDurationView: View {
  var viewModel: SessionEditViewModel?
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Длительность сессии")
        .foregroundStyle(.secondary)
        .font(.footnote)
      Text(viewModel?.getFormattedDuration() ?? "")
    }
  }
}

#Preview {
  SessionDurationView()
}
