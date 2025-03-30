import Constant
import Foundation
import OpenAI
import Service

@Observable
public class TodayDataModel {
    // TODO: これ使わずにformattedでいいかも
    static var stepCountFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = .current
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        return dateFormatter
    }

    // Today
    public var todayStepCount: StepCount = .noData
    public var todayDistance: DistanceWalkingRunning = .noData
    public var yesterdayStepCount: StepCount = .noData

    public var goalStreak: Int = 0

    private let healthDataClient: HealthDataClientProtocol
    private let openAI = OpenAI(apiToken: Secret.openAI.rawValue)

    public init(
        healthDataClient: HealthDataClientProtocol
    ) {
        self.healthDataClient = healthDataClient
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

    public func generateAdvise() async throws {
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .day, value: -1, to: .now),
              let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) else {
            return
        }
        let stepData = try await healthDataClient.loadStepCount(start: startDate, end: endDate)
        let formattedData = stepData
            .map { (date, stepCount) in "\(Self.stepCountFormatter.string(from: date)): \(stepCount.number)" }
            .joined(separator: ",")
        let query = ChatQuery(
            messages: [
                // システムメッセージでパーソナルトレーナーとしての基本コンテキストを設定
                .init(role: .system, content: "あなたは歩数系アプリのパーソナルトレーナーです。性格は明るいです。")!,
                // ユーザーメッセージで過去の歩数データに基づく解析と改善アドバイスの生成を依頼
                .init(role: .user, content: """
                過去の歩数データから週間および月間のトレンドを解析し、解析の結果を簡単にサマライズしてください。
                その結果を元に、例えば歩数が低下傾向にある場合には具体的な改善アドバイスを提供してください。
                出力はjson形式です。
                {\"trend\":\"...\",\"advice\":\"...\"}
                それ以外の追加のキーは不要です。
                
                以下はここ1ヶ月の歩数データです。これを元に出力を作成してください。
                \(formattedData)
                """)!
            ],
            model: .gpt4_o,
            responseFormat: .jsonObject
        )
        do {
            let result = try await openAI.chats(query: query)
            if let contentString = result.choices.first?.message.content?.string,
               let jsonData = contentString.data(using: .utf8) {
                do {
                    let analysisResult = try JSONDecoder().decode(AnalysisResult.self, from: jsonData)
                    // TODO: 表示する
                } catch {
                    throw TodayDataModelError.failedToDecodeJson
                }
            } else {
                throw TodayDataModelError.failedToLoadData(nil)
            }
        } catch {
            throw TodayDataModelError.failedToLoadData(error)
        }
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
    struct AnalysisResult: Codable {
        let trend: String
        let advice: String
    }

    enum TodayDataModelError: LocalizedError {
        case failedToDecodeJson
        case failedToLoadData(Error?)
    }
}
