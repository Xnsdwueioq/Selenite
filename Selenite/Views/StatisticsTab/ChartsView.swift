//
//  ChartsView.swift
//  Selenite
//
//  Created by Eyhciurmrn Zmpodackrl on 20.04.2026.
//

import SwiftUI
import SwiftData
import Charts

struct ChartsView: View {
  @Bindable var viewModel: StatisticsViewModel
  
  private let chartPalette: [Color] = [.blue, .purple, .pink, .orange, .yellow, .green, .mint]
  
  var body: some View {
    Group {
      Chart(viewModel.groupedSessions) { group in
        SectorMark(
          angle: .value("Длительность", group.totalDuration),
          innerRadius: .ratio(0.6),
          angularInset: 2
        )
        .foregroundStyle(by: .value("Название", group.title))
        .cornerRadius(4)
        .opacity(viewModel.selectedGroupName == nil || viewModel.selectedGroupName == group.title ? 1.0 : 0.5)
      }
      .frame(height: 250)
      .padding()
      .chartForegroundStyleScale(range: chartPalette)
      .chartLegend(.hidden)
      .chartAngleSelection(value: $viewModel.selectedGroupName)
      
      if let selected = viewModel.selectedGroupName {
        VStack {
          Text(selected)
            .font(.headline)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .frame(width: 100)
          
          if let group = viewModel.groupedSessions.first(where: { $0.title == selected }) {
            Text(calculatePercentage(for: group.totalDuration))
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
      }
      
      List {
        Section {
          Picker("Период", selection: $viewModel.selectedTimeRange.animation(.snappy)) {
            ForEach(StatisticsViewModel.TimeRange.allCases, id: \.self) { range in
              Text(range.rawValue).tag(range)
            }
          }
          .pickerStyle(.segmented)
          ForEach(Array(viewModel.groupedSessions.enumerated()), id: \.element.id) { index, group in
            HStack {
              Circle()
                .fill(chartPalette[index % chartPalette.count])
                .frame(width: 8, height: 8)
              
              VStack(alignment: .leading) {
                Text(group.title)
                  .font(.headline)
                Text(formatTime(group.totalDuration))
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              
              Spacer()
              
              Text(calculatePercentage(for: group.totalDuration))
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
                .foregroundStyle(.purpleBrand)
            }
          }
        }
        .listStyle(.insetGrouped)
      }
    }
    .onChange(of: viewModel.selectedTimeRange) { viewModel.selectedGroupName = nil }
  }
  
  // MARK: - Helpers
  
  private func calculatePercentage(for duration: TimeInterval) -> String {
    let total = viewModel.totalPeriodDuration
    guard total > 0 else { return "0%" }
    let percentage = (duration / total) * 100
    return String(format: "%.1f%%", percentage)
  }
  
  private func formatTime(_ interval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: interval) ?? "0м"
  }
}

#Preview {
  let container: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Period.self, PeriodInterval.self, configurations: config)
    let context = container.mainContext
    
    let now = Date()
    
    // 1. Короткая сессия (10 минут)
    let session1 = Period(title: "Hi, im business informatic", startDate: now.addingTimeInterval(-3600))
    let interval1 = PeriodInterval(
      startTime: now.addingTimeInterval(-3600),
      endTime: now.addingTimeInterval(-3000)
    )
    session1.intervals = [interval1]
    session1.fragmentedType = session1.calculateFragmentedType
    
    // 2. Прерванная сессия (два интервала по 15 минут с перерывом)
    let session2 = Period(title: "Daniil Samuhin", startDate: now.addingTimeInterval(-7200))
    let interval2a = PeriodInterval(
      startTime: now.addingTimeInterval(-7200),
      endTime: now.addingTimeInterval(-6300)
    )
    let interval2b = PeriodInterval(
      startTime: now.addingTimeInterval(-5400),
      endTime: now.addingTimeInterval(-4500)
    )
    session2.intervals = [interval2a, interval2b]
    session2.fragmentedType = session2.calculateFragmentedType
    
    let session3 = Period(title: "Glad to see u", startDate: now.addingTimeInterval(-10800))
    let interval3 = PeriodInterval(
      startTime: now.addingTimeInterval(-10800),
      endTime: now.addingTimeInterval(-9000)
    )
    session3.intervals = [interval3]
    session3.fragmentedType = session3.calculateFragmentedType
    
    let session4 = Period(title: "Glad to see u", startDate: now.addingTimeInterval(-220800))
    let interval4 = PeriodInterval(
      startTime: now.addingTimeInterval(-250800),
      endTime: now.addingTimeInterval(-50200)
    )
    session4.intervals = [interval4]
    session4.fragmentedType = session4.calculateFragmentedType
    context.insert(session4)
    // Вставляем все сессии в контекст
    context.insert(session1)
    context.insert(session2)
    context.insert(session3)
    
    return container
  }()
  
  StatisticsView()
    .modelContainer(container)
    .tint(.purpleBrand)
}
