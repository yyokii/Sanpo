import Model
import Charts
import StyleGuide
import SwiftUI

struct SummaryView: View {
    @Environment(MyDataModel.self) private var myDataModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Weekly", bundle: .module)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.black)
                Spacer(minLength: 16).fixedSize()
                weeklySummaryData
                    .padding(.horizontal, 8)
                Spacer(minLength: 24).fixedSize()
                Text("Monthly", bundle: .module)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.black)
                Spacer(minLength: 16).fixedSize()
                monthlySummaryData
                    .padding(.horizontal, 8)
                Spacer(minLength: 24).fixedSize()
            }
            .padding(.horizontal, 8)
        }
    }
}

private extension SummaryView {
    func weekAgoText(for date: Date) -> String {
        let weeksAgo = Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 0
        if weeksAgo == 0 {
            return String(localized: "This week", bundle: .module)
        } else {
            return String(localized: "\(weeksAgo) week ago", bundle: .module)
        }
    }

    func monthAgoText(for date: Date) -> String {
        let weeksAgo = Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 0
        if weeksAgo == 0 {
            return String(localized: "This week", bundle: .module)
        } else {
            return String(localized: "\(weeksAgo) week ago", bundle: .module)
        }
    }

    var lastWeekData: StepCountSummary.ChartData? {
        guard myDataModel.stepCountSummary.weekly.count > 2 else {
            return nil
        }
        return  myDataModel.stepCountSummary.weekly[1]
    }

    var lastMonthData: StepCountSummary.ChartData? {
        guard myDataModel.stepCountSummary.monthly.count > 2 else {
            return nil
        }
        return  myDataModel.stepCountSummary.monthly[1]
    }


    @ViewBuilder
    var weeklySummaryData: some View {
        if let lastWeekData {
            VStack(alignment: .center, spacing: 0) {
                averageStepsText(
                    myDataModel.stepCountSummary.weekly.first?.y ?? 0,
                    comparisonStepCount: lastWeekData.y
                )
                .padding(.horizontal, 8)
                Spacer(minLength: 20).fixedSize()
                chartView(data: myDataModel.stepCountSummary.weekly.reversed())
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .adaptiveShadow()
        }
    }

    @ViewBuilder
    var monthlySummaryData: some View {
        if let lastMonthData {
            VStack(alignment: .center, spacing: 0) {
                averageStepsText(
                    myDataModel.stepCountSummary.monthly.first?.y ?? 0,
                    comparisonStepCount: lastMonthData.y
                )
                .padding(.horizontal, 8)
                Spacer(minLength: 20).fixedSize()
                chartView(data: myDataModel.stepCountSummary.monthly.reversed())
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .adaptiveShadow()
        }
    }

    func averageStepsText(_ stepCount: Int, comparisonStepCount: Int) -> some View {
        let diff = stepCount - comparisonStepCount
        let diffPercentage = calculatePercentage(current: stepCount, previous: comparisonStepCount)
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
                        Text("\(diff >= 0 ? "+" : "")\(diff) (\(String(format: "%.1f", diffPercentage))%)")
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
    func chartView(data: [StepCountSummary.ChartData]) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Chart {
                ForEach(data, id: \.self) { chartData in
                    BarMark(
                        x: .value("x", chartData.x),
                        y: .value("Steps", chartData.y),
                        width: .ratio(0.5)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.black.opacity(0.8), .gray],
                            startPoint: .bottom,
                            endPoint: .top)
                    )
                    .annotation(position: .top) {
                        Text("\(chartData.y)")
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
