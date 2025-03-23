import Foundation

public struct MockAIClient: AIClientProtocol {
    public init() {}

    public func generateWalkingAdviceWithWeather(currentWeather: CurrentWeather, hourlyWeather: [HourWeather]) async throws -> WeatherWalkingAdvice {
        .init(
            advice: "🌈Perfect walking weather!",
            recommendedTime: "Enjoy your walk"
        )
    }
}
