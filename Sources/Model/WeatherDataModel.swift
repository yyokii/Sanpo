import Foundation
import Service

@Observable
public class WeatherDataModel {
    public var mainSunEvents: MainSunEvents?

    private let weatherDataClient: WeatherDataClientProtocol
    private let locationManager: LocationManagerProtocol

    public init(
        weatherDataClient: WeatherDataClientProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.weatherDataClient = weatherDataClient
        self.locationManager = locationManager

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
    }

    public func load() async {
        guard let location = locationManager.location else { return }
        mainSunEvents = await weatherDataClient.loadTodayMainSunEvents(for: location)
    }
}
