import Constant
import Foundation
import OpenAI

public protocol AIClientProtocol {
    func generateWalkingAdviceWithWeather(currentWeather: CurrentWeather, hourlyWeather: [HourWeather]) async throws -> WeatherWalkingAdvice
    func generateStepCountAdvise(stepData: [Date: StepCount]) async throws -> StepCountAnalysis
}

public struct AIClient: AIClientProtocol {
    public static let shared = Self()

    public init() {}

    private let openAI = OpenAI(apiToken: Secret.openAI.rawValue)

    public func generateWalkingAdviceWithWeather(currentWeather: CurrentWeather, hourlyWeather: [HourWeather]) async throws -> WeatherWalkingAdvice {
        let currentDescription = "Current temperature is \(currentWeather.temperature.value.rounded())°C, condition is \(currentWeather.condition.title). Humidity is \((currentWeather.humidity * 100).rounded())%, wind is blowing from \(currentWeather.windDirection.description) at \(currentWeather.windSpeed.value.rounded())km/h."
        let hourlyForecast = hourlyWeather
            .map { hourWeather in
                "\(hourWeather.date.formatted(date: .omitted, time: .shortened)): \(hourWeather.temperature.value.rounded())°C, Precipitation \((hourWeather.precipitationChance * 100).rounded())%"
            }
            .joined(separator: "\n")
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: """
                    You are a friendly and calm walking advisor. Based on the current weather and the next 25-hour forecast (including the current weather), generate a very short walking advice in English. Your response should be a natural, casual one-liner—something like "Perfect walking weather!"—that avoids any system-like tone.
                    Provide two separate pieces of information:
                    1. A one-line friendly advice message, starting with a randomly chosen emoji. For example:
                       - For ideal conditions, randomly choose one emoji from [ "👍", "😊", "☀️", "🌈", "🌸" ] and produce a message like "Perfect walking weather!"
                       - For moderately favorable conditions, randomly choose one emoji from [ "🙂", "😎", "🦶" ] and produce a message like "Almost walkable!"
                       - For unsuitable conditions, randomly choose one emoji from [ "🌧️", "⛈️", "🌩️" ] and produce a message like "Not a good time for a walk."
                    2. A recommended time suggestion for a walk. If conditions are good, indicate until what time they remain ideal; if not, suggest when conditions might improve.
                    Return your output as a JSON object with two keys:
                    {
                        "advice": "<your one-liner friendly walking advice including the emoji>",
                        "recommendedTime": "<the recommended time period or suggestion for a walk>"
                    }
                    """)!,
                .init(role: .user, content: """
                    [Current Weather]
                    \(currentDescription)

                    [Next 25-Hour Forecast]
                    \(hourlyForecast)

                    Use the above information to generate the walking advice.
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
                    return try JSONDecoder().decode(WeatherWalkingAdvice.self, from: jsonData)
                } catch {
                    throw AIClientError.failedToDecodeJson
                }
            } else {
                throw AIClientError.failedToLoadData(nil)
            }
        } catch {
            throw AIClientError.failedToLoadData(error)
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

    public func generateStepCountAdvise(stepData: [Date:StepCount]) async throws -> StepCountAnalysis {
        let formattedData = stepData
            .map { (date, stepCount) in "\(Self.stepCountFormatter.string(from: date)): \(stepCount.number)" }
            .joined(separator: ",")

        let query = ChatQuery(
            messages: [
                .init(role: .system, content: "You are a personal trainer in a step counting app. Your personality is cheerful and encouraging.")!,
                .init(role: .user, content: """
                Analyze the weekly and monthly trends from the past step count data and provide a brief summary.
                Based on the analysis, provide specific improvement advice, especially if there's a declining trend.
                Output must be in JSON format with the following keys only:
                "trend": A short one- or two-sentence summary of the step count trend.
                "advice": A short one- or two-sentence advice for improvement.
                Do not include any other keys or extra explanations.
                Here is the step count data for the past month:
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
                    return try JSONDecoder().decode(StepCountAnalysis.self, from: jsonData)
                } catch {
                    throw AIClientError.failedToDecodeJson
                }
            } else {
                throw AIClientError.failedToLoadData(nil)
            }
        } catch {
            throw AIClientError.failedToLoadData(error)
        }
    }
}

public enum AIClientError: LocalizedError {
    case failedToDecodeJson
    case failedToLoadData(Error?)
    case noWeatherData
}
