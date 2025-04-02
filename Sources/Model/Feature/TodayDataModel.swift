import Foundation
import Service

@Observable
public class TodayDataModel {
    // Today
    public var todayStepCount: StepCount = .noData
    public var todayDistance: DistanceWalkingRunning = .noData
    public var yesterdayStepCount: StepCount = .noData

    public var goalStreak: Int = 0

    private let healthDataClient: HealthDataClientProtocol
    private let aiClient: AIClientProtocol

    public init(
        healthDataClient: HealthDataClientProtocol,
        aiClient: AIClientProtocol
    ) {
        self.healthDataClient = healthDataClient
        self.aiClient = aiClient
    }

    public func load() async {
        let now: Date = .now

        if let stepCount = try? await healthDataClient.loadStepCount(for: now) {
            self.todayStepCount = stepCount
        }
        if let distance = try? await healthDataClient.loadDistanceWalkingRunning(for: now) {
            self.todayDistance = distance
        }
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now),
           let yesterdayStepCount = try? await healthDataClient.loadStepCount(for: yesterday) {
            self.yesterdayStepCount = yesterdayStepCount
        }
    }

    /// ここ1ヶ月分のデータでアドバイスを生成する
    public func generateAdvise() async throws -> StepCountAnalysis {
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .day, value: -1, to: .now),
              let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) else {
            throw TodayDataModelError.failedToLoadData(nil)
        }
        let stepData = try await healthDataClient.loadStepCount(start: startDate, end: endDate)
        return try await aiClient.generateStepCountAdvise(stepData: stepData)
    }

    /// 昨日から過去100日分の歩数データで、指定した目標歩数を達成した連続日数を更新
    public func updateCurrentStepGoalStreak(goal: Int) async throws {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)

        // 本日の途中データは含めず、昨日を基準にする
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday) else {
            return
        }
        // 昨日からさかのぼって、最大100日分（昨日含む）のデータをチェックするため、昨日の99日前の日付を取得
        guard let startDate = calendar.date(byAdding: .day, value: -99, to: yesterday) else {
            return
        }

        let stepData = try await healthDataClient.loadStepCount(start: startDate, end: yesterday)

        var streak = 0
        var currentDate = yesterday

        // 昨日から最大100日分ループ（100日以上の連続達成なら "99+" として返す）
        for _ in 0..<100 {
            let day = calendar.startOfDay(for: currentDate)
            guard let stepCount = stepData[day] else { break }
            if stepCount.number >= goal {
                streak += 1
            } else {
                break
            }
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        goalStreak = streak
    }
}


extension TodayDataModel {
    enum TodayDataModelError: LocalizedError {
        case failedToLoadData(Error?)
    }
}
