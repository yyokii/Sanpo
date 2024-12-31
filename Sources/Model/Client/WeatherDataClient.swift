import Foundation
import CoreLocation
import WeatherKit

public protocol WeatherDataClientProtocol {

    func loadHourlyForecast(for location: CLLocation) async -> [HourWeather]?
    func loadCurrentWeather(for location: CLLocation) async -> CurrentWeather?
}

public struct WeatherDataClient: WeatherDataClientProtocol {

    private let service = WeatherService.shared

    public func loadHourlyForecast(for location: CLLocation) async -> [HourWeather]? {
        let forecast = try? await self.service.weather(
            for: location,
            including: .hourly
        ).forecast
        return forecast?.compactMap { HourWeather.init(from: $0) }
    }
    
    public func loadCurrentWeather(for location: CLLocation) async -> CurrentWeather? {
        let forecast = try? await self.service.weather(
            for: location,
            including: .current
        )
        return .init(from: forecast)
    }
}
