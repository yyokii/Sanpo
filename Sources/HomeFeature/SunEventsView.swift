import SwiftUI
import WeatherKit

import Model
import Service

struct SunEventsView: View {
    @State private var width: CGFloat = 0
    @StateObject private var locationService = LocationService.shared

    let now: Date
    let sunEvents: MainSunEvents
    private let currentMarSize: CGFloat = 30

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: createGradient(),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 60)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ContentWidthPreferenceKey.self, value: geometry.size.width)
                        }
                    )
                    .onPreferenceChange(ContentWidthPreferenceKey.self) {
                        width = $0
                    }
                currentMark
            }

            if let bottomText {
                Text(bottomText)
                    .adaptiveFont(.normal, size: 24)
            }
        }
    }
}

extension SunEventsView {
    struct MainSunEvents {
        /// 太陽の中心が地平線下18°に位置する時刻。この時、空に僅かな光が差し始め、星が徐々に見えなくなる。
        var astronomicalDawn: Date

        ///  日の出
        var sunrise: Date

        /// 太陽が空で最も高い位置に達する時刻
        var solarNoon: Date

        /// 日の入り
        var sunset: Date

        /// 太陽の中心が地平線下18°に達し、空が完全に暗くなり、天体観測に支障がなくなる時刻。
        var astronomicalDusk: Date


        private var totalDuration: TimeInterval {
            astronomicalDusk.timeIntervalSince(astronomicalDawn)
        }

        init?(from sunEvents: SunEvents) {
            // できれば nil を許容した表示にもしたい
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

        func location(of keyPath: KeyPath<MainSunEvents, Date>) -> Double {
            let date = self[keyPath: keyPath]
            return date.timeIntervalSince(astronomicalDawn) / totalDuration
        }

        func location(of date: Date) -> Double {
            return date.timeIntervalSince(astronomicalDawn) / totalDuration
        }
    }
}

private extension SunEventsView {
    func createGradient() -> Gradient {
        return Gradient(stops: [
            .init(color: Color.hex(0xE0F7FA), location: 0),
            .init(color: Color.hex(0xFFECB3), location: CGFloat(sunEvents.location(of: \.sunrise))),
            .init(color: Color.hex(0xFFF9C4), location: CGFloat(sunEvents.location(of: \.solarNoon))),
            .init(color: Color.hex(0xFFAB91), location: CGFloat(sunEvents.location(of: \.sunset))),
            .init(color: Color.hex(0xB39DDB), location: CGFloat(sunEvents.location(of: \.astronomicalDusk))),
            .init(color: Color.hex(0x9FA8DA), location: 1)
        ])
    }

    var currentMark: some View {
        Circle()
            .fill(Color.white.opacity(0.4))
            .frame(width: currentMarSize, height: currentMarSize)
            .overlay(currentMarkIcon)
            .offset(x: calculateCircleOffset(), y: 0)
    }

    var currentMarkIcon: some View {
        var icon: String
        if now < sunEvents.astronomicalDawn {
            icon = "🌙"
        } else if now >= sunEvents.astronomicalDawn, now < sunEvents.astronomicalDusk {
            icon = "☀️"
        } else {
            icon = "🌙"
        }
        return Text(icon)
            .font(.system(size: 24))
    }

    // 現在の日時に基づいて円の位置を計算
    func calculateCircleOffset() -> CGFloat {
        let currentTimeLocation = sunEvents.location(of: now)

        if currentTimeLocation < 0 {
            return 0
        } else if currentTimeLocation > 1 {
            return width - currentMarSize
        } else {
            return CGFloat(currentTimeLocation) * width - currentMarSize / 2
        }
    }

    func badgeText(_ text: String) -> some View {
        Text(text)
            .adaptiveFont(.normal, size: 8)
            .foregroundStyle(Color.adaptiveWhite)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(Color.adaptiveBlack)
            }
    }

    var bottomText: String? {
        let remainingTimeForDawn = Int(sunEvents.astronomicalDawn.timeIntervalSince(now))
        let remainingTimeForDusk = Int(sunEvents.astronomicalDusk.timeIntervalSince(now))

        if now < sunEvents.astronomicalDawn && remainingTimeForDawn <= 3600 * 3 {
            // 日の出まで3時間以内
            let hours = remainingTimeForDawn / 3600
            let minutes = (remainingTimeForDawn % 3600) / 60
            return "日の出まであと\(hours):\(minutes)"
        } else if now < sunEvents.astronomicalDusk && remainingTimeForDawn <= 3600 * 3 {
            // 日の入りまで3時間以内
            let hours = remainingTimeForDusk / 3600
            let minutes = (remainingTimeForDusk % 3600) / 60
            return "日の入りまであと\(hours):\(minutes)"
        } else {
            return nil
        }
    }
}

struct ContentWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { .zero }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

#if DEBUG

extension SunEventsView.MainSunEvents {

    init(
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

    static var previewValue: Self {
        // 特定の日付を設定
        let year = 2024
        let month = 2
        let day = 1
        let timeZone = TimeZone(identifier: "Asia/Tokyo")!

        var calendar = Calendar.current
        calendar.timeZone = timeZone

        // 時刻を設定（5:00, 6:30, 12:00, 17:00, 19:00）
        let times = [(5, 0), (6, 30), (12, 0), (17, 0), (19, 0), (24, 0)]

        let dates = times.map { (hour, minute) -> Date in
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            return calendar.date(from: dateComponents)!
        }

        return SunEventsView.MainSunEvents(
            astronomicalDawn: dates[0],
            sunrise: dates[1],
            solarNoon: dates[2],
            sunset: dates[3],
            astronomicalDusk: dates[4]
        )
    }
}

#Preview {
    SunEventsView(
        now: Date(),
        sunEvents: .previewValue
    )
}

#endif
