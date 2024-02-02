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
    @Published public var todayForecast: DayWeather?
    private var location: CLLocation?

    private let service = WeatherService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        locationService.$location
            .sink { location in
                if let location = location {
                    self.location = location
                    Task.detached(priority: .userInitiated) {
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
                    await self.loadTodayForecast(for: location)
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
        hourlyForecasts = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(
                for: location,
                including: .hourly
            )
            return forecast
        }.value
    }

    private func loadTodayForecast(for location: CLLocation) async {
        phase = .loading
        let dayForecasts = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(
                for: location,
                including: .daily
            )
            return forecast
        }.value
        todayForecast = dayForecasts?.forecast[0]
    }
}
