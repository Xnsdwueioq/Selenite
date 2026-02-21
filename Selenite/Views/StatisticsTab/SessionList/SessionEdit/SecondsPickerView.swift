//
//  SecondsPickerView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 21.02.2026.
//

import SwiftUI

struct SecondsPickerView: View {
  @Binding var date: Date
  var secondsRange: Range<Int> = 0..<60
  
  @State private var showSecondsPicker = false
  
  var body: some View {
    Button(action: { showSecondsPicker.toggle() }) {
      ZStack {
        Capsule()
          .foregroundStyle(Color(UIColor.tertiarySystemFill))
          .frame(width: 70, height: 35)
        
        Text(String(format: "%02d''", Calendar.current.component(.second, from: date)))
          .foregroundColor(.primary)
          .monospacedDigit()
      }
    }
    .buttonStyle(.plain)
    .popover(isPresented: $showSecondsPicker) {
      VStack {
        Picker("Секунды",
               selection: Binding(
                get: {
                  Calendar.current.component(.second, from: date)
                },
                set: { newValue in
                  date = date.setSeconds(seconds: newValue)
                }
               )
        ) {
          ForEach(secondsRange, id: \.self) { second in
            Text("\(second)").tag(second)
          }
        }
        .pickerStyle(.wheel)
        .frame(width: 100, height: 150)
      }
      .presentationCompactAdaptation(.popover)
    }
  }
}

#Preview {
  NavigationStack {
    SessionEditView(session: Period(intervals: [
      PeriodInterval(
        startTime: Date(),
        endTime: Date().advanced(by: 120)
      ),
      PeriodInterval(startTime: Date().advanced(by: 140), endTime: Date().advanced(by: 2523))
    ]))
    .tint(.purpleBrand)
  }
}
