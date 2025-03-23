import Constant
import WeatherKit
import Foundation
import Service

@Observable
public class WeatherDataModel {
    public var mainSunEvents: MainSunEvents?
    public var currentWeather: CurrentWeather?
    public var hourlyWeather: [HourWeather]?
    public var weatherDataAttribution: WeatherDataAttribution?
    public var weatherWalkingAdvice: WeatherWalkingAdvice?

    private let weatherDataClient: WeatherDataClientProtocol
    private let locationManager: LocationManagerProtocol
    private let aiClient: AIClientProtocol

    public init(
        weatherDataClient: WeatherDataClientProtocol,
        locationManager: LocationManagerProtocol,
        aiClient: AIClientProtocol
    ) {
        self.weatherDataClient = weatherDataClient
        self.locationManager = locationManager
        self.aiClient = aiClient

        // 位置情報が更新されたら天候データの再取得を行う
        // https://forums.developer.apple.com/forums/thread/746466
        // https://www.youtube.com/watch?v=DAq-eA98O4g
        _ = withObservationTracking {
            self.locationManager.location
        } onChange: {
            Task {
                await self.load()
            }
        }
        Task {
            weatherDataAttribution = await weatherDataClient.loadWeatherAttribution()
        }
    }

    public func load() async {
        guard let location = locationManager.location else { return }
        
        async let sunEvents = weatherDataClient.loadTodayMainSunEvents(for: location)
        async let current = weatherDataClient.loadCurrentWeather(for: location)
        async let hourly = weatherDataClient.loadHourlyForecast(for: location)
        
        // 並列で取得した結果を代入
        (mainSunEvents, currentWeather, hourlyWeather) = await (sunEvents, current, hourly)
    }
    
    public func generateWalkingAdvice() async throws {
        guard let currentWeather, let hourlyWeather else { return }
        weatherWalkingAdvice =  try? await aiClient.generateWalkingAdviceWithWeather(
            currentWeather: currentWeather,
            hourlyWeather: hourlyWeather
        )
    }
}
