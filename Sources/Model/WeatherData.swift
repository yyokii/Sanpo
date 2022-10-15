import Combine
import CoreLocation
import Foundation
import WeatherKit
import os

import Extension
import Service

/**
 The data provider that loads weather forecast data.
 */
@MainActor
public class WeatherData: ObservableObject {
    let logger = Logger(category: .model)

    @Published public var state: AsyncStatePhase = .initial
    @Published public var hourlyForecasts: Forecast<HourWeather>?
    private var location: CLLocation?

    private let service = WeatherService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        locationService.$location
            .sink { location in
                if let location = location {
                    Task.detached(priority: .userInitiated) {
                        await self.loadHourlyForecast(for: location)
                    }
                }
            }
            .store(in: &cancellables)
    }

    public func loadHourlyForecast(for location: CLLocation) async {
        state = .loading
        let hourWeather = await Task.detached(priority: .userInitiated) {
            let forcast = try? await self.service.weather(
                for: location,
                including: .hourly
            )
            return forcast
        }.value
        hourlyForecasts = hourWeather
        state = .success(Date())
    }

    public func requestLocationAuth() {
        locationService.requestWhenInUseAuthorization()
    }
}
