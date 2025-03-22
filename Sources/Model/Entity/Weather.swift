import Foundation
import WeatherKit

public struct CurrentWeather {
    public let date: Date
    public let symbolName: String
    public let condition: WeatherCondition
    public let humidity: Double
    public let temperature: Measurement<UnitTemperature>
    public let uvIndexCategory: UVIndex.ExposureCategory
    public let windSpeed: Measurement<UnitSpeed>
    public let windDirection: Wind.CompassDirection

    public init?(from currentWeather: WeatherKit.CurrentWeather?) {
        guard let currentWeather else {
            return nil
        }
        self.date = currentWeather.date
        self.symbolName = currentWeather.symbolName
        self.condition = currentWeather.condition
        self.humidity = currentWeather.humidity
        self.temperature = currentWeather.temperature
        self.uvIndexCategory = currentWeather.uvIndex.category
        self.windSpeed = currentWeather.wind.speed
        self.windDirection = currentWeather.wind.compassDirection
    }

    public init(
        date: Date,
        symbolName: String,
        condition: WeatherCondition,
        humidity: Double,
        temperature: Measurement<UnitTemperature>,
        uvIndexCategory: UVIndex.ExposureCategory,
        windSpeed: Measurement<UnitSpeed>,
        windDirection: Wind.CompassDirection
    ) {
        self.date = date
        self.symbolName = symbolName
        self.condition = condition
        self.humidity = humidity
        self.temperature = temperature
        self.uvIndexCategory = uvIndexCategory
        self.windSpeed = windSpeed
        self.windDirection = windDirection
    }
}

public struct HourWeather {
    public let date: Date
    public let symbolName: String
    public let precipitationChance: Double
    public let temperature: Measurement<UnitTemperature>

    public init(from hourWeather: WeatherKit.HourWeather) {
        self.date = hourWeather.date
        self.symbolName = hourWeather.symbolName
        self.precipitationChance = hourWeather.precipitationChance
        self.temperature = hourWeather.temperature
    }

    public init(
        date: Date,
        symbolName: String,
        precipitationChance: Double,
        temperature: Measurement<UnitTemperature>
    ) {
        self.date = date
        self.symbolName = symbolName
        self.precipitationChance = precipitationChance
        self.temperature = temperature
    }
}

extension WeatherCondition {
    var title: String {
        switch self {
        case .clear, .mostlyClear:
            return String(localized: "weather-condition-clear", bundle: .module)
        case .cloudy, .mostlyCloudy, .partlyCloudy:
            return String(localized: "weather-condition-cloudy", bundle: .module)
        case .breezy, .windy:
            return String(localized: "weather-condition-windy", bundle: .module)
        case .foggy, .haze, .smoky:
            return String(localized: "weather-condition-fog", bundle: .module)
        case .drizzle, .rain, .heavyRain, .freezingDrizzle, .freezingRain, .sunShowers:
            return String(localized: "weather-condition-rain", bundle: .module)
        case .isolatedThunderstorms, .scatteredThunderstorms, .thunderstorms, .strongStorms, .hurricane, .tropicalStorm:
            return String(localized: "weather-condition-thunderstorm", bundle: .module)
        case .blizzard, .blowingSnow, .flurries, .heavySnow, .snow, .sleet, .sunFlurries, .wintryMix:
            return String(localized: "weather-condition-snow", bundle: .module)
        case .blowingDust:
            return String(localized: "weather-condition-dust", bundle: .module)
        case .hail:
            return String(localized: "weather-condition-hail", bundle: .module)
        case .frigid:
            return String(localized: "weather-condition-frigid", bundle: .module)
        case .hot:
            return String(localized: "weather-condition-hot", bundle: .module)
        @unknown default:
            return ""
        }
    }
}

#if DEBUG

extension CurrentWeather {
    public static var mock: Self = .init(
        date: Date(),
        symbolName: "sun.max",
        condition: WeatherCondition(rawValue: "rain")!,
        humidity: 0.34567891111,
        temperature: .ValueType(value: 34.567, unit: .celsius),
        uvIndexCategory: .moderate,
        windSpeed: .ValueType(value: 12.3456777, unit: .kilometersPerHour),
        windDirection: .north
    )
}

extension HourWeather {
    public static var mock: [Self] = {
        let now: Date = .now

        return [
            .init(
                date: Calendar.current.date(byAdding: .hour, value: 0, to: now)!,
                symbolName: "sun.max",
                precipitationChance: 0,
                temperature: .ValueType(value: 24, unit: .celsius)
            ),
            .init(
                date: Calendar.current.date(byAdding: .hour, value: 1, to: now)!,
                symbolName: "sun.max",
                precipitationChance: 0,
                temperature: .ValueType(value: 24, unit: .celsius)
            ),
            .init(
                date: Calendar.current.date(byAdding: .hour, value: 2, to: now)!,
                symbolName: "sun.max",
                precipitationChance: 0,
                temperature: .ValueType(value: 24, unit: .celsius)
            ),
            .init(
                date: Calendar.current.date(byAdding: .hour, value: 3, to: now)!,
                symbolName: "sun.max",
                precipitationChance: 0,
                temperature: .ValueType(value: 24, unit: .celsius)
            ),
            .init(
                date: Calendar.current.date(byAdding: .hour, value: 4, to: now)!,
                symbolName: "sun.max",
                precipitationChance: 0,
                temperature: .ValueType(value: 24, unit: .celsius)
            ),
            .init(
                date: Calendar.current.date(byAdding: .hour, value: 5, to: now)!,
                symbolName: "sun.max",
                precipitationChance: 0,
                temperature: .ValueType(value: 24, unit: .celsius)
            )
        ]
    }()
}

#endif
