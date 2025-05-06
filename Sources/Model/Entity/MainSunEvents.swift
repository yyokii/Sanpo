import Foundation
import WeatherKit

public struct MainSunEvents: Equatable {
    /// 太陽の中心が地平線下18°に位置する時刻。この時、空に僅かな光が差し始め、星が徐々に見えなくなる。
    public var astronomicalDawn: Date

    ///  日の出
    public var sunrise: Date

    /// 太陽が空で最も高い位置に達する時刻
    public var solarNoon: Date

    /// 日の入り
    public var sunset: Date

    /// 太陽の中心が地平線下18°に達し、空が完全に暗くなり、天体観測に支障がなくなる時刻。
    public var astronomicalDusk: Date

    public init?(from sunEvents: SunEvents) {
        guard let astronomicalDawn = sunEvents.astronomicalDawn,
              let sunrise = sunEvents.sunrise,
              let solarNoon = sunEvents.solarNoon,
              let sunset = sunEvents.sunset,
              let astronomicalDusk = sunEvents.astronomicalDusk else {
            return nil
        }
        self.astronomicalDawn = astronomicalDawn
        self.sunrise = sunrise
        self.solarNoon = solarNoon
        self.sunset = sunset
        self.astronomicalDusk = astronomicalDusk
    }

    public init(
        astronomicalDawn: Date,
        sunrise: Date,
        solarNoon: Date,
        sunset: Date,
        astronomicalDusk: Date
    ) {
        self.astronomicalDawn = astronomicalDawn
        self.sunrise = sunrise
        self.solarNoon = solarNoon
        self.sunset = sunset
        self.astronomicalDusk = astronomicalDusk
    }
}
