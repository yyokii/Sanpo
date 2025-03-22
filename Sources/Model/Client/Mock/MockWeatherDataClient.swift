import Foundation
import CoreLocation
import WeatherKit

public struct MockWeatherDataClient: WeatherDataClientProtocol {
    public init() {}

    public func loadHourlyForecast(for location: CLLocation) async -> [HourWeather]? {
        let now: Date = .now
        return [
            .init(
                date: now,
                symbolName: "sun",
                precipitationChance: .random(in: 0.1...0.9),
                temperature: .init(value: .random(in: 4...40), unit: .celsius)
            ),
            .init(
                date: now.addingTimeInterval(3600),
                symbolName: "cloud.sun",
                precipitationChance: .random(in: 0.1...0.9),
                temperature: .init(value: .random(in: 1...40), unit: .celsius)
            )
        ]
    }

    public func loadCurrentWeather(for location: CLLocation) async -> CurrentWeather? {
        .init(
            date: Date(),
            symbolName: "sun.max",
            condition: WeatherCondition(rawValue: "rain")!,
            humidity: .random(in: 0...0.5),
            temperature: .ValueType(value: .random(in: 1...40), unit: .celsius),
            uvIndexCategory: .moderate,
            windSpeed: .ValueType(value: .random(in: 1...20), unit: .kilometersPerHour),
            windDirection: .north
        )
    }

    public func loadTodayMainSunEvents(for location: CLLocation) async -> MainSunEvents? {
        let now = Date()
        return .init(
            astronomicalDawn: now.addingTimeInterval(-7200),
            sunrise: now.addingTimeInterval(-3600),
            solarNoon: now.addingTimeInterval(18000),
            sunset: now.addingTimeInterval(36000),
            astronomicalDusk: now.addingTimeInterval(43200)
        )
    }
}
