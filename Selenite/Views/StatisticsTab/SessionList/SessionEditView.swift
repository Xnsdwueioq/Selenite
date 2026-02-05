//
//  SessionEditView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 06.02.2026.
//

import SwiftUI

struct SessionEditView: View {
  var session: Period
  let notEndedTime = "Не завершено"
  
  var body: some View {
    List {
      Section {
        VStack(alignment: .leading) {
          Text("Название")
            .foregroundStyle(.secondary)
            .font(.footnote)
          Text(session.title.description)
        }
        
        VStack(alignment: .leading) {
          Text("Длительность сессии")
            .foregroundStyle(.secondary)
            .font(.footnote)
          Text(session.formattedDuration)
        }
      }
      
      Section(content: {
        ForEach(session.intervals) { interval in
          Section {
            VStack(alignment: .leading) {
              Text("Время начала")
                .foregroundStyle(.secondary)
                .font(.footnote)
              Text(interval.startTime.formatted())
            }
            
            VStack(alignment: .leading) {
              Text("Время конца")
                .foregroundStyle(.secondary)
                .font(.footnote)
              Text(interval.endTime?.formatted() ?? notEndedTime)
            }
          }
        }
      }, header: {
        Text("Интервалы")
      })
    }
  }
}

#Preview {
  SessionEditView(session: Period(intervals: [
    PeriodInterval(
      startTime: Date(),
      endTime: Date().advanced(by: 120)
    ),
    PeriodInterval(startTime: Date().advanced(by: 140), endTime: Date().advanced(by: 2523))
  ]))
}
