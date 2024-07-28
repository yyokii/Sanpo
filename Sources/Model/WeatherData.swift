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
    @Published public var hourlyForecasts: [HourWeather]?
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

//    public init(
//        hourlyForecasts: [HourWeather],
//        currentWeather: CurrentWeather
//    ) {
//        self.hourlyForecasts = hourlyForecasts
//        self.currentWeather = currentWeather
//        self.phase = .success(.now)
//    }

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
            ).forecast
            return forecast?.compactMap { HourWeather.init(from: $0) }
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
        self.currentWeather = .init(from: currentWeather)
    }
}

#if DEBUG
extension WeatherData {
    convenience init(
        hourlyForecasts: [HourWeather],
        currentWeather: CurrentWeather
    ) {
        self.init()
        self.hourlyForecasts = hourlyForecasts
        self.currentWeather = currentWeather
        self.phase = .success(.now)
    }

    public static let preview: WeatherData = .init(hourlyForecasts: HourWeather.mock, currentWeather: .mock)
}
#endif
