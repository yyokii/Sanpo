import Foundation

public struct StepCountSummary {
    public let weekly: [ChartData]
    public let monthly: [ChartData]

    public struct ChartData: Hashable {
        public let x: String
        public let y: Int
    }
}

@Observable
public class MyDataModel {

    public var stepCounts: [Date: StepCount] = [:]
    public var stepCountSummary: StepCountSummary = .init(weekly: [], monthly: [])

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

    public func loadStepCountSummary() async throws {
        let calendar = Calendar.current
        let now: Date = .now
        // Calculate start and end dates for weekly data (last 4 weeks including this week)
        let startOfWeeklyData = calendar.date(byAdding: .weekOfYear, value: -3, to: Date())! // 4 weeks including this week
        // Calculate start and end dates for monthly data (last 6 months including this month)
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let startOfMonthlyData = calendar.date(byAdding: .month, value: -5, to: startOfCurrentMonth)! // 6 months including this month

        async let weeklyData = healthDataClient.loadWeeklyAverageStepCount(start: startOfWeeklyData, end: now)
        async let monthlyData = healthDataClient.loadMonthlyAverageStepCount(start: startOfMonthlyData, end: now)

        let (weeklyResult, monthlyResult) = try await (weeklyData, monthlyData)
        self.stepCountSummary = .init(
            weekly: weeklyResult
                .sorted(by: { $0.key > $1.key })
                .map {.init(x: makeWeekAgoText(for: $0.key), y: $0.value.number)},
            monthly: monthlyResult
                .sorted(by: { $0.key > $1.key })
                .map {.init(x: makeMonthAgoText(for: $0.key), y: $0.value.number)}
        )
    }

    func makeWeekAgoText(for date: Date) -> String {
        let weeksAgo = Calendar.current.dateComponents([.weekOfYear], from: date, to: Date()).weekOfYear ?? 0
        if weeksAgo == 0 {
            return String(localized: "This week", bundle: .module)
        } else {
            return String(localized: "\(weeksAgo) weeks ago", bundle: .module)
        }
    }

    func makeMonthAgoText(for date: Date) -> String {
        let monthsAgo = Calendar.current.dateComponents([.month], from: date, to: Date()).month ?? 0
        if monthsAgo == 0 {
            return String(localized: "This month", bundle: .module)
        } else {
            return String(localized: "\(monthsAgo) months ago", bundle: .module)
        }
    }
}
