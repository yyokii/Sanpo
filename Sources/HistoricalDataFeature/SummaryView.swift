import Model
import Charts
import StyleGuide
import SwiftUI

struct SummaryView: View {

    let metricData: MetricData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                chartView
            }
            .padding(.horizontal, 8)
        }
    }
}

private extension SummaryView {
    @ViewBuilder
    var chartView: some View {
        VStack(alignment: .center, spacing: 0) {
            switch metricData {
            case let .stepCount(monthlyData, yearlyData):
                let sortedYearlyData = yearlyData.sorted(by: { $0.key < $1.key })
                Chart {
                    ForEach(sortedYearlyData, id: \ .key) { year, stepCount in
                        BarMark(
                            x: .value("Year", String(year)),
                            y: .value("Steps", stepCount.number),
                            width: .ratio(0.6)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.black.opacity(0.8), .gray],
                                startPoint: .bottom,
                                endPoint: .top)
                        )
                        .annotation(position: .top) {
                            Text("\(stepCount.number)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .clipShape(Capsule())
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        // X軸はラベルのみを表示し、ラインは表示しない
                        AxisValueLabel()
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartScrollPosition(initialX: String(sortedYearlyData.last?.key ?? 0))
                .chartXVisibleDomain(length: 5)
                .chartYAxis(.hidden)
            case .walkingLength(let monthly, let yearly):
                EmptyView()
            case .walkingSpeed(let monthly, let yearly):
                EmptyView()
            }
        }
        .frame(height: 300)
        .padding(.vertical, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .adaptiveShadow()
    }
}

#Preview {
    var monthlyData: [Date: StepCount] {
        let calendar = Calendar.current
        let now = Date()
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        var mockData: [Date: StepCount] = [:]

        for i in 0..<3 {
            if let monthStartDate = calendar.date(byAdding: .month, value: -i, to: startOfCurrentMonth) {
                let monthEndDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStartDate)!
                mockData[monthStartDate] = StepCount(
                    start: monthStartDate,
                    end: monthEndDate,
                    number: .random(in: 100...50000)
                )
            }
        }

        return mockData
    }

    SummaryView(
        metricData:
                .stepCount(
                    monthly: monthlyData,
                    yearly:  [
                        2019: .init(start: .now, end: .now, number: .random(in: 100...40000)),
                        2020: .init(start: .now, end: .now, number: .random(in: 100...40000)),
                        2021: .init(start: .now, end: .now, number: .random(in: 100...40000)),
                        2022: .init(start: .now, end: .now, number: .random(in: 100...40000)),
                        2023: .init(start: .now, end: .now, number: .random(in: 100...40000)),
                        2024: .init(start: .now, end: .now, number: .random(in: 100...40000)),
                        2025: .init(start: .now, end: .now, number: .random(in: 100...40000))
                    ]
                )
    )
    .padding()
}
