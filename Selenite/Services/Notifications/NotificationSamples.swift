//
//  NotificationSamples.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 7/28/26.
//

#if DEBUG
import Foundation
import SwiftUI
import FocusCore

nonisolated enum NotificationSamples {

  struct Sample: Sendable, Identifiable, CustomStringConvertible {
    let name: String
    let boundary: PhaseBoundary
    let title: String
    let body: String

    var id: String { name }
    var description: String { name }
  }

  static let sessionLength: TimeInterval = 25 * 60
  static let shortBreakLength: TimeInterval = 5 * 60
  static let longBreakLength: TimeInterval = 15 * 60
  static let anyDate = Date(timeIntervalSince1970: 0)

  static func spelled(_ seconds: TimeInterval) -> String {
    Duration.seconds(seconds).formatted(.units(allowed: [.hours, .minutes], width: .wide))
  }

  static let all: [Sample] = [
    Sample(
      name: "сессия → короткий перерыв, авто",
      boundary: PhaseBoundary(
        endingPhase: .work(index: 0),
        completionAt: anyDate,
        nextPhase: .shortBreak(afterIndex: 0),
        nextPhaseDuration: shortBreakLength,
        nextPhaseStartsAutomatically: true
      ),
      title: "Сессия завершена",
      body: "Начинается: короткий перерыв, \(spelled(shortBreakLength))"
    ),
    Sample(
      name: "сессия → короткий перерыв, вручную",
      boundary: PhaseBoundary(
        endingPhase: .work(index: 0),
        completionAt: anyDate,
        nextPhase: .shortBreak(afterIndex: 0),
        nextPhaseDuration: shortBreakLength,
        nextPhaseStartsAutomatically: false
      ),
      title: "Сессия завершена",
      body: "Далее: короткий перерыв, \(spelled(shortBreakLength))"
    ),
    Sample(
      name: "сессия → сессия, короткие перерывы выключены, авто",
      boundary: PhaseBoundary(
        endingPhase: .work(index: 0),
        completionAt: anyDate,
        nextPhase: .work(index: 1),
        nextPhaseDuration: sessionLength,
        nextPhaseStartsAutomatically: true
      ),
      title: "Сессия завершена",
      body: "Начинается: сессия, \(spelled(sessionLength))"
    ),
    Sample(
      name: "сессия → сессия, короткие перерывы выключены, вручную",
      boundary: PhaseBoundary(
        endingPhase: .work(index: 0),
        completionAt: anyDate,
        nextPhase: .work(index: 1),
        nextPhaseDuration: sessionLength,
        nextPhaseStartsAutomatically: false
      ),
      title: "Сессия завершена",
      body: "Далее: сессия, \(spelled(sessionLength))"
    ),
    Sample(
      name: "короткий перерыв → сессия, авто",
      boundary: PhaseBoundary(
        endingPhase: .shortBreak(afterIndex: 0),
        completionAt: anyDate,
        nextPhase: .work(index: 1),
        nextPhaseDuration: sessionLength,
        nextPhaseStartsAutomatically: true
      ),
      title: "Перерыв завершён",
      body: "Начинается: сессия, \(spelled(sessionLength))"
    ),
    Sample(
      name: "короткий перерыв → сессия, вручную",
      boundary: PhaseBoundary(
        endingPhase: .shortBreak(afterIndex: 0),
        completionAt: anyDate,
        nextPhase: .work(index: 1),
        nextPhaseDuration: sessionLength,
        nextPhaseStartsAutomatically: false
      ),
      title: "Перерыв завершён",
      body: "Далее: сессия, \(spelled(sessionLength))"
    ),
    Sample(
      name: "последняя сессия → длинный перерыв, авто",
      boundary: PhaseBoundary(
        endingPhase: .work(index: 3),
        completionAt: anyDate,
        nextPhase: .longBreak,
        nextPhaseDuration: longBreakLength,
        nextPhaseStartsAutomatically: true
      ),
      title: "Сессия завершена",
      body: "Начинается: длинный перерыв, \(spelled(longBreakLength))"
    ),
    Sample(
      name: "последняя сессия → длинный перерыв, вручную",
      boundary: PhaseBoundary(
        endingPhase: .work(index: 3),
        completionAt: anyDate,
        nextPhase: .longBreak,
        nextPhaseDuration: longBreakLength,
        nextPhaseStartsAutomatically: false
      ),
      title: "Сессия завершена",
      body: "Далее: длинный перерыв, \(spelled(longBreakLength))"
    ),
    Sample(
      name: "длинный перерыв → конец цикла",
      boundary: PhaseBoundary(
        endingPhase: .longBreak,
        completionAt: anyDate,
        nextPhase: .finished,
        nextPhaseDuration: nil,
        nextPhaseStartsAutomatically: true
      ),
      title: "Цикл завершён",
      body: "Все сессии пройдены. Вернитесь в приложение для старта нового цикла"
    ),
    Sample(
      name: "последняя сессия → конец цикла, длинный перерыв выключен",
      boundary: PhaseBoundary(
        endingPhase: .work(index: 3),
        completionAt: anyDate,
        nextPhase: .finished,
        nextPhaseDuration: nil,
        nextPhaseStartsAutomatically: false
      ),
      title: "Цикл завершён",
      body: "Все сессии пройдены. Вернитесь в приложение для старта нового цикла"
    ),
  ]
}

#Preview("Уведомления на границах фаз") {
  ScrollView {
    VStack(alignment: .leading, spacing: 20) {
      ForEach(NotificationSamples.all) { sample in
        let content = NotificationContentBuilder.content(for: sample.boundary)

        VStack(alignment: .leading, spacing: 6) {
          Text(sample.name)
            .font(.caption2)
            .foregroundStyle(.secondary)

          HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
              .fill(.tint)
              .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
              Text(content.title)
                .font(.footnote.weight(.semibold))
              Text(content.body)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
          }
          .padding(12)
          .background(.regularMaterial, in: .rect(cornerRadius: 18, style: .continuous))
        }
      }
    }
    .padding()
  }
  .background(Color(.systemGroupedBackground))
}
#endif
