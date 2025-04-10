import Components
import Model
import Charts
import StyleGuide
import SwiftUI

public struct SummaryView: View {
    @Environment(MyDataModel.self) private var myDataModel

    public  init() {}

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: 0) {
                Group {
                    CardView {
                        weeklySummaryData
                    }

                    CardView {
                        monthlySummaryData
                    }
                }
                .padding(.vertical, 20)
                .containerRelativeFrame(.horizontal)
                .scrollTransition(axis: .horizontal) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                }
            }
            .scrollTargetLayout()
        }
        .safeAreaPadding(.horizontal, 40)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
    }
}

private extension SummaryView {
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
                TitleChip("Weekly Average")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 16).fixedSize()

                averageStepsText(
                    myDataModel.stepCountSummary.weekly.first?.y ?? 0,
                    comparisonStepCount: lastWeekData.y
                )
                .padding(.horizontal, 8)

                Spacer(minLength: 20).fixedSize()

                chartView(data: myDataModel.stepCountSummary.weekly.reversed())
            }
        }
    }

    @ViewBuilder
    var monthlySummaryData: some View {
        if let lastMonthData {
            VStack(alignment: .center, spacing: 0) {
                TitleChip("Monthly Average")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 16).fixedSize()

                averageStepsText(
                    myDataModel.stepCountSummary.monthly.first?.y ?? 0,
                    comparisonStepCount: lastMonthData.y
                )
                .padding(.horizontal, 8)

                Spacer(minLength: 20).fixedSize()

                chartView(data: myDataModel.stepCountSummary.monthly.reversed())
            }
        }
    }

    func averageStepsText(_ stepCount: Int, comparisonStepCount: Int) -> some View {
        let diff = stepCount - comparisonStepCount
        let diffPercentage = calculatePercentage(current: stepCount, previous: comparisonStepCount)
        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text("\(stepCount)")
                        .font(.large)
                        .bold()
                    Text("steps", bundle: .module)
                        .font(.small)
                        .foregroundStyle(.gray)
                }
                Spacer(minLength: 4).fixedSize()
                if let diffPercentage {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: diff >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                            .foregroundStyle(diff >= 0 ? .green : .red)
                        Text("\(diff >= 0 ? "+" : "")\(diff) (\(String(format: "%.1f", diffPercentage))%)")
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
                        width: .ratio(0.3)
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
        .frame(height: 90)
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
