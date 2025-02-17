import Constant
import Foundation
import OpenAI
import Service

@Observable
public class TodayDataModel {

    public var todayStepCount: StepCount = .noData
    public var mainSunEvents: MainSunEvents?

    private let healthDataClient: HealthDataClientProtocol
    private let weatherDataClient: WeatherDataClientProtocol
    private let locationManager: LocationManagerProtocol
    private let openAI = OpenAI(apiToken: Secret.openAI.rawValue)

    public init(
        healthDataClient: HealthDataClientProtocol,
        weatherDataClient: WeatherDataClientProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.healthDataClient = healthDataClient
        self.weatherDataClient = weatherDataClient
        self.locationManager = locationManager

        // 位置情報が更新されたら天候データの再取得を行う
        // https://forums.developer.apple.com/forums/thread/746466
        _ = withObservationTracking {
            self.locationManager.location
        } onChange: {
            Task {
                await self.load()
            }
        }
    }

    public func load() async {
        guard let location = locationManager.location else { return }
        mainSunEvents = await weatherDataClient.loadTodayMainSunEvents(for: location)
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

    static var stepCountFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = .current
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        return dateFormatter
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
