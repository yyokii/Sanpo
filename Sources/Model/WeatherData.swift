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

    @Published public var phase: AsyncStatePhase = .initial
    @Published public var hourlyForecasts: Forecast<HourWeather>?
    @Published public var currentWeather: CurrentWeather?
    private var location: CLLocation?

    private let service = WeatherService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        locationService.$location
            .sink { location in
                if let location = location {
                    self.location = location
                    Task {
                        await self.load()
                    }
                }
            }
            .store(in: &cancellables)
    }

    public func load() async {
        if let location {
            await withTaskGroup(of: Void.self) { group in
                group.addTask(priority: .userInitiated) {
                    await self.loadHourlyForecast(for: location)
                }
                group.addTask(priority: .userInitiated) {
                    await self.loadCurrentWeather(for: location)
                }
                for await _ in group {}
                phase = .success(Date())
            }
        }
    }

    public func requestLocationAuth() {
        locationService.requestWhenInUseAuthorization()
    }

    private func loadHourlyForecast(for location: CLLocation) async {
        phase = .loading
        hourlyForecasts = await Task {
            let forecast = try? await self.service.weather(
                for: location,
                including: .hourly
            )
            return forecast
        }.value
    }

    private func loadCurrentWeather(for location: CLLocation) async {
        phase = .loading
        let currentWeather = await Task {
            let forecast = try? await self.service.weather(
                for: location,
                including: .current
            )
            return forecast
        }.value
        self.currentWeather = currentWeather
    }
}
