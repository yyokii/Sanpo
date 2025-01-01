import Foundation

public enum Metric {
    case stepCount
}

public enum MetricData {
    case stepCount(monthly: [Date: StepCount], yearly: [Int: StepCount])
    case walkingLength(monthly: [Int: Int], yearly: [Int: Int])
    case walkingSpeed(monthly: [Int: Float], yearly: [Int: Float])
}

@Observable
public class MyDataModel {

    public var stepCounts: [Date: StepCount] = [:]
    public var metricData: [Metric: MetricData] = [:]

    private let healthDataClient: HealthDataClientProtocol

    public init(healthDataClient: HealthDataClientProtocol) {
        self.healthDataClient = healthDataClient
    }

    public func loadStepCounts() async {
        let calendar = Calendar.current
        // HealthKit is available from iOS 8(2014/9/17)
        let startDate = DateComponents(year: 2014, month: 9, day: 1, hour: 0, minute: 0, second: 0)
        if let stepCounts = try? await healthDataClient.loadStepCount(
            start: calendar.date(from: startDate)!,
            end: Date()
        ) {
            self.stepCounts = stepCounts
        }
    }

    public func loadSummaryDate(metric: Metric) async throws {
        let calendar = Calendar.current
        // HealthKit is available from iOS 8(2014/9/17)
        let startDate = DateComponents(year: 2014, month: 9, day: 1, hour: 0, minute: 0, second: 0)
        switch metric {
        case .stepCount:
            async let monthlyData = healthDataClient.loadMonthlyStepCount(
                start: calendar.date(from: startDate)!,
                end: .now
            )
            async let yearlyData = healthDataClient.loadYearlyStepCount(
                startYear: 2015,
                endYear: calendar.component(.year, from: .now)
            )
            let (monthlyResult, yearlyResult) = try await (monthlyData, yearlyData)
            metricData[.stepCount] = .stepCount(monthly: monthlyResult, yearly: yearlyResult)
        }
    }
}
