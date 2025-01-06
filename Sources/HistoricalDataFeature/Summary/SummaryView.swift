import Model
import Charts
import StyleGuide
import SwiftUI

struct SummaryView: View {
    @Environment(MyDataModel.self) private var myDataModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                weeklySummaryData(data: myDataModel.stepCountSummary.weekly)
            }
        }
    }
}

private extension SummaryView {
    func weekAgoText(for date: Date) -> String {
        let weeksAgo = Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 0
        if weeksAgo == 0 {
            return "This week"
        } else {
            return "\(weeksAgo) week ago"
        }
    }

    var sortedWeeklyData: [Dictionary<Date, StepCount>.Element] {
        myDataModel.stepCountSummary.weekly.sorted(by: { $0.key < $1.key })
    }

    var lastWeekData: Dictionary<Date, StepCount>.Element? {
        if sortedWeeklyData.count > 2 {
            sortedWeeklyData[sortedWeeklyData.count - 2]
        } else {
            nil
        }
    }

    @ViewBuilder
    func weeklySummaryData(data: [Date:StepCount]) -> some View {
        if let lastWeekData {
            VStack(alignment: .center, spacing: 0) {

                averageStepsText(
                    stepCount: sortedWeeklyData.last?.value.number ?? 0,
                    lastWeekStepCount: lastWeekData.value.number
                )
                .padding(.horizontal, 8)
                Spacer(minLength: 16).fixedSize()
                chartView(data: sortedWeeklyData)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .adaptiveShadow()
        }
    }

    func averageStepsText(stepCount: Int, lastWeekStepCount: Int) -> some View {
        let diff = stepCount - lastWeekStepCount
        let diffPercentage = calculatePercentage(current: stepCount, previous: lastWeekStepCount)
        return VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 4).fixedSize()

            VStack(alignment: .center, spacing: 0) {
                Text("Average Steps")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Text("\(stepCount)")
                    .font(.system(size: 44))
                    .bold()
                Spacer(minLength: 2).fixedSize()
                if let diffPercentage {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: diff >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                            .foregroundStyle(diff >= 0 ? .green : .red)
                        Text("\(diff >= 0 ? "+" : "-")\(diff) (\(String(format: "%.1f", diffPercentage))%)")
                            .font(.caption)
                            .foregroundStyle(diff >= 0 ? .green : .red)
                        Text("from last week")
                            .font(.caption)
                            .foregroundStyle(diff >= 0 ? .green : .red)
                    }
                }
            }
        }
    }

    func calculatePercentage(current: Int, previous: Int) -> Double? {
        guard previous != 0 else {
            // 前週の歩数がゼロの場合の処理
            return nil
        }
        let diff = current - previous
        return (Double(diff) / Double(previous)) * 100
    }

    @ViewBuilder
    func chartView(data: [Dictionary<Date, StepCount>.Element]) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Chart {
                ForEach(data, id: \ .key) { week, stepCount in
                    BarMark(
                        x: .value("Week", weekAgoText(for: week)),
                        y: .value("Steps", stepCount.number),
                        width: .ratio(0.5)
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
            .chartXVisibleDomain(length: 5)
            .chartYAxis(.hidden)
        }
        .frame(height: 240)
    }
}

#Preview {
    @Previewable @State var myDataModel = MyDataModel(healthDataClient: MockHealthDataClient())

    SummaryView()
        .environment(myDataModel)
        .onAppear {
            Task {
                try? await myDataModel.loadStepCountSummary()
            }
        }
}
