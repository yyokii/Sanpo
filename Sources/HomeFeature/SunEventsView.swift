import SwiftUI
import WeatherKit

import Model

struct SunEventsView: View {
    @State private var width: CGFloat = 0

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
            HStack(alignment: .center, spacing: 0) {
                bottomText("日の出")
                Spacer(minLength: 8)
                bottomText("深夜")
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension SunEventsView {
    struct MainSunEvents {
        var astronomicalDawn: Date
        var sunrise: Date
        var solarNoon: Date
        var sunset: Date
        var astronomicalDusk: Date
        var solarMidnight: Date

        private var totalDuration: TimeInterval {
            solarMidnight.timeIntervalSince(astronomicalDawn)
        }

        init?(from sunEvents: SunEvents) {
            print(sunEvents)
            // できれば nil を許容した表示にもしたい
            guard let astronomicalDawn = sunEvents.astronomicalDawn,
                  let sunrise = sunEvents.sunrise,
                  let solarNoon = sunEvents.solarNoon,
                  let sunset = sunEvents.sunset,
                  let astronomicalDusk = sunEvents.astronomicalDusk,
                  let solarMidnight = sunEvents.solarMidnight else {
                return nil
            }

            self.astronomicalDawn = astronomicalDawn
            self.sunrise = sunrise
            self.solarNoon = solarNoon
            self.sunset = sunset
            self.astronomicalDusk = astronomicalDusk
            self.solarMidnight = solarMidnight
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

        print(CGFloat(sunEvents.location(of: \.sunrise)))
        print(CGFloat(sunEvents.location(of: \.solarNoon)))
        print(CGFloat(sunEvents.location(of: \.sunset)))
        print(CGFloat(sunEvents.location(of: \.astronomicalDusk)))

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

    func bottomText(_ text: String) -> some View {
        Text(text)
            .adaptiveFont(.normal, size: 12)
            .foregroundStyle(Color.adaptiveWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(Color.adaptiveBlack)
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
        astronomicalDusk: Date,
        solarMidnight: Date
    ) {
        self.astronomicalDawn = astronomicalDawn
        self.sunrise = sunrise
        self.solarNoon = solarNoon
        self.sunset = sunset
        self.astronomicalDusk = astronomicalDusk
        self.solarMidnight = solarMidnight
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
            astronomicalDusk: dates[4],
            solarMidnight: dates[5]
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
