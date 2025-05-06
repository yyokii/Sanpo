import Foundation
import CoreLocation
import WeatherKit

public protocol WeatherDataClientProtocol {
    func loadHourlyForecast(for location: CLLocation) async -> [HourWeather]?
    func loadCurrentWeather(for location: CLLocation) async -> CurrentWeather?
    func loadTodayMainSunEvents(for location: CLLocation) async -> MainSunEvents?
    func loadWeatherAttribution () async -> WeatherDataAttribution?
}

public struct WeatherDataClient: WeatherDataClientProtocol {
    public static let shared = WeatherDataClient()

    private let service = WeatherService.shared

    private init() {}

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

    public func loadTodayMainSunEvents(for location: CLLocation) async -> MainSunEvents? {
        let forecast = try? await self.service.weather(
            for: location,
            including: .daily
        )
        guard let sunEvents = forecast?.forecast.first?.sun else {
            return nil
        }
        // TODO: forecast?.forecast.firstの天気、特にconditionが現地の様子と違う気がするのは、locationの値の問題なのか？要確認
        return .init(from: sunEvents)
    }

    public func loadWeatherAttribution() async -> WeatherDataAttribution? {
        let attribution = try? await service.attribution
        return .init(imageURL: attribution?.combinedMarkLightURL, url: attribution?.legalPageURL)
    }
}
