import Foundation

public struct MockAIClient: AIClientProtocol {
    public init() {}

    public func generateWalkingAdviceWithWeather(currentWeather: CurrentWeather, hourlyWeather: [HourWeather]) async throws -> WeatherWalkingAdvice {
        .init(
            advice: "🌈Perfect walking weather!",
            recommendedTime: "Enjoy your walk"
        )
    }

    public func generateStepCountAdvise(stepData: [Date : StepCount]) async throws -> StepCountAnalysis {
        .init(
            trend: "loreum ipsum loreum ipsum loreum ipsum loreum ipsum loreum ipsum",
            advice: "loreum ipsum loreum ipsum loreum ipsum loreum ipsum loreum ipsum"
        )
    }
}
