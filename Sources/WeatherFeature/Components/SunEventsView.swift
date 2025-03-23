import SwiftUI
import Model
import Service

struct SunEventsView: View {
    let now: Date
    let sunEvents: MainSunEvents

    var body: some View {
        WidthSizeReader { width in
            let arcHeight = width * 0.3
            SunArcShape(arcHeight: arcHeight)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.yellow.opacity(0.8),
                                Color.orange.opacity(0.8),
                                Color.purple.opacity(0.8)
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
                .frame(maxWidth: .infinity)
                .frame(height: arcHeight)
                .overlay {
                    sunImage
                        .position(sunPosition(width: width, arcHeight: arcHeight))
                }
        }
    }

    /// 現在時刻に基づいて、アーク上の太陽／月の位置を算出する。
    /// マッピングは以下の通り（左上が原点）：
    /// - sunrise で t = 0 (左端)
    /// - solarNoon で t = 0.5 (最高点)
    /// - sunset で t = 1 (右端)
    func sunPosition(width: CGFloat, arcHeight: CGFloat) -> CGPoint {
        let startPoint = CGPoint(x: 0, y: arcHeight)
        let endPoint = CGPoint(x: width, y: arcHeight)
        // アークの最高点は、制御点として中央上（x: width/2, y: 0）に設定
        let controlPoint = CGPoint(x: width / 2, y: 0)

        // 現在時刻の位置を、上記のルールに従って t を算出
        let t = mappedT(for: now)
        let oneMinusT = 1 - t

        // Quadratic Bezier の公式
        let x = oneMinusT * oneMinusT * startPoint.x +
        2 * oneMinusT * t * controlPoint.x +
        t * t * endPoint.x
        let y = oneMinusT * oneMinusT * startPoint.y +
        2 * oneMinusT * t * controlPoint.y +
        t * t * endPoint.y

        return CGPoint(x: x, y: y)
    }

    /// 現在時刻を sunrise, solarNoon, sunset に基づいて t (0〜1) にマッピングする。
    func mappedT(for currentTime: Date) -> CGFloat {
        if currentTime <= sunEvents.sunrise {
            return 0
        } else if currentTime >= sunEvents.sunset {
            return 1
        } else if currentTime <= sunEvents.solarNoon {
            let interval = sunEvents.solarNoon.timeIntervalSince(sunEvents.sunrise)
            let elapsed = currentTime.timeIntervalSince(sunEvents.sunrise)
            guard interval > 0 else { return 0 }
            let fraction = elapsed / interval
            return CGFloat(fraction * 0.5)
        } else {
            let interval = sunEvents.sunset.timeIntervalSince(sunEvents.solarNoon)
            let elapsed = currentTime.timeIntervalSince(sunEvents.solarNoon)
            guard interval > 0 else { return 1 }
            let fraction = elapsed / interval
            return 0.5 + CGFloat(fraction * 0.5)
        }
    }

    /// 現在時刻に合わせた太陽／月のアイコンを返す
    var sunImage: some View {
        let icon: String
        if now < sunEvents.sunrise {
            icon = "🌙"
        } else if now < sunEvents.astronomicalDusk {
            icon = "☀️"
        } else {
            icon = "🌙"
        }
        return Text(icon)
            .font(.system(size: 30))
            .padding(4)
            .background {
                Circle()
                    .fill(.thinMaterial)
            }
    }
}

/// Quadratic Bezier 曲線を用いてアークを描画する Shape
struct SunArcShape: Shape {
    var arcHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let baseline = rect.height
        let startPoint = CGPoint(x: 0, y: baseline)
        let endPoint = CGPoint(x: width, y: baseline)
        // 制御点は中央上部（x: width/2, y: 0）
        let controlPoint = CGPoint(x: width / 2, y: 0)

        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, control: controlPoint)
        return path
    }
}

#if DEBUG

extension MainSunEvents {
    static var previewValue: Self {
        // 特定の日付を設定
        let now = Date()
        let calendar = Calendar.current
        let dawn = calendar.date(byAdding: .hour, value: -1, to: now)!
        let sunrise = calendar.date(byAdding: .hour, value: -2, to: now)!
        let solarNoon = now
        let sunset = calendar.date(byAdding: .hour, value: 4, to: now)!
        let dusk = calendar.date(byAdding: .hour, value: 8, to: now)!
        return MainSunEvents(
            astronomicalDawn: dawn,
            sunrise: sunrise,
            solarNoon: solarNoon,
            sunset: sunset,
            astronomicalDusk: dusk
        )
    }
}

struct WidthSizeReader<Content: View>: View {
    struct WidthPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat { .zero }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    }

    @State private var width: CGFloat = 0
    private let content: (_ width: CGFloat) -> Content
    var body: some View {
        content(width)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: WidthPreferenceKey.self, value: proxy.size.width)
                }
            }
            .onPreferenceChange(WidthPreferenceKey.self) {
                width = $0
            }
    }

    init(@ViewBuilder content: @escaping (_: CGFloat) -> Content) {
        self.content = content
    }
}

#Preview {
    SunEventsView(
        now: Date(),
        sunEvents: .previewValue
    )
    .border(.red)
    .padding(.horizontal)
}

#endif
