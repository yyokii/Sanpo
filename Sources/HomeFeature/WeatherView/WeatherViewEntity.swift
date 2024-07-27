import Foundation
import WeatherKit

extension WeatherDataView {
    struct CurrentWeather {
        let date: Date
        let symbolName: String
        let humidity: Double
        let temperature: Measurement<UnitTemperature>
        let uvIndexCategory: UVIndex.ExposureCategory
        let windSpeed: Measurement<UnitSpeed>
        let windDirection: Wind.CompassDirection

        init?(from currentWeather: WeatherKit.CurrentWeather?) {
            guard let currentWeather else {
                return nil
            }
            self.date = currentWeather.date
            self.symbolName = currentWeather.symbolName
            self.humidity = currentWeather.humidity
            self.temperature = currentWeather.temperature
            self.uvIndexCategory = currentWeather.uvIndex.category
            self.windSpeed = currentWeather.wind.speed
            self.windDirection = currentWeather.wind.compassDirection
        }

        init(
            date: Date,
            symbolName: String,
            humidity: Double,
            temperature: Measurement<UnitTemperature>,
            uvIndexCategory: UVIndex.ExposureCategory,
            windSpeed: Measurement<UnitSpeed>,
            windDirection: Wind.CompassDirection
        ) {
            self.date = date
            self.symbolName = symbolName
            self.humidity = humidity
            self.temperature = temperature
            self.uvIndexCategory = uvIndexCategory
            self.windSpeed = windSpeed
            self.windDirection = windDirection
        }
    }

    struct HourWeather {
        let date: Date
        let symbolName: String
        let precipitationChance: Double
        let temperature: Measurement<UnitTemperature>

        init(from hourWeather: WeatherKit.HourWeather) {
            self.date = hourWeather.date
            self.symbolName = hourWeather.symbolName
            self.precipitationChance = hourWeather.precipitationChance
            self.temperature = hourWeather.temperature
        }

        init(date: Date, symbolName: String, precipitationChance: Double, temperature: Measurement<UnitTemperature>) {
            self.date = date
            self.symbolName = symbolName
            self.precipitationChance = precipitationChance
            self.temperature = temperature
        }
    }
}

extension UVIndex.ExposureCategory {
    var label: String {
        switch self {
        case .low:
            return String(localized: "uv-low", bundle: .module)
        case .moderate:
            return String(localized: "uv-moderate", bundle: .module)
        case .high:
            return String(localized: "uv-high", bundle: .module)
        case .veryHigh:
            return String(localized: "uv-veryHigh", bundle: .module)
        case .extreme:
            return String(localized: "uv-extreme", bundle: .module)
        }
    }
}
