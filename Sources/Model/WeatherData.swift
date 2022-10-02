import CoreLocation
import Foundation
import WeatherKit
import os

/**
 The data provider that loads weather forecast data.
 */
@MainActor
class WeatherData: ObservableObject {
    let logger = Logger(subsystem: "com.yyokii.sanpo.StepCountData.WeatherData", category: "Model")

    @Published private var hourlyForecasts: Forecast<HourWeather>?

    private let service = WeatherService.shared

    func loadHourlyForecast(for location: CLLocation) async {
        let hourWeather = await Task.detached(priority: .userInitiated) {
            let forcast = try? await self.service.weather(
                for: location,
                including: .hourly)
            return forcast
        }.value
        hourlyForecasts = hourWeather
    }
}