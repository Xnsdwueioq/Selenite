//
//  SessionTitleView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 12.02.2026.
//

import SwiftUI


struct SessionTitleView: View {
  var viewModel: SessionEditViewModel?
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Название")
        .foregroundStyle(.secondary)
        .font(.footnote)
      TextField(
        "Название",
        text: Binding(
          get: {
            viewModel?.draftSessionTitle ?? "Selenite"
          },
          set: { newTitle in
            viewModel?.draftSessionTitle = newTitle
          }),
        prompt: Text("Selenite")
      )
    }
  }
}
