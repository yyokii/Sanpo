import SwiftUI
import WeatherKit
import Model
import SafariView
import StyleGuide
import Service

public struct WeatherDataView: View {
    @Environment(WeatherDataModel.self) private var weatherDataModel
    @State private var showWeatherKitLegalLink = false

    public init() {}

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
//            ZStack(alignment: .center) {
//                TypingTextView(text: "")
//                    .font(.large)
//                    .padding(.horizontal, 32)
//            }
//            .frame(maxHeight: .infinity)

            VStack(alignment: .center, spacing: 0) {
                if let weatherWalkingAdvice = weatherDataModel.weatherWalkingAdvice {
                    Text(weatherWalkingAdvice.advice)
                        .font(.large)
                    Spacer(minLength: 8).fixedSize()
                    Text(weatherWalkingAdvice.recommendedTime)
                        .font(.medium)
                }
            }
            .frame(maxHeight: .infinity)
            weather()
        }
        .background {
            BlobBackgroundView()
        }
        .onAppear {
            Task {
                await weatherDataModel.load()
                try? await weatherDataModel.generateWalkingAdvice()
            }
        }
        .sheet(isPresented: $showWeatherKitLegalLink) {
            if let weatherDataAttribution = weatherDataModel.weatherDataAttribution {
                SafariView(url: weatherDataAttribution.url)
            }
        }
    }
}

private extension WeatherDataView {
    func weather() -> some View {
        VStack(alignment: .center, spacing: 0) {
            if let currentWeather = weatherDataModel.currentWeather,
               let sunEvents = weatherDataModel.mainSunEvents {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        currentWeatherTemperature(currentWeather)
                        Spacer(minLength: 16)
                        SunEventsCard(mainSunEvents: sunEvents)
                            .frame(width: 160)
                    }
                    Spacer(minLength: 16).fixedSize()
                    currentWeatherDetail(currentWeather)
                }
                .padding(.horizontal, 16)
            }

            Spacer(minLength: 16).fixedSize()

            if let hourlyForecasts = weatherDataModel.hourlyWeather {
                VStack(alignment: .leading, spacing: 12) {
                    Text("hourly-weather-title", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.medium)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal) {
                        HStack(alignment: .center, spacing: 10) {
                            ForEach(hourlyForecasts.prefix(12), id: \.date) { forecast in
                                hourlyWeatherDataItem(forecast)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
    }

    func currentWeatherTemperature(_ weather: Model.CurrentWeather) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(weather.condition.title)
                .font(.x2Large)
                .bold()
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text("\(Int(weather.temperature.value))")
                    .font(.x2Large)
                    .bold()
                Text("\(weather.temperature.unit.symbol)")
                    .font(.medium)
            }
        }
    }

    func currentWeatherDetail(_ weather: Model.CurrentWeather) -> some View {
        HStack(alignment: .top, spacing: 0) {
            currentWeatherItem(
                titleKey: "uv-title",
                value: weather.uvIndexCategory.label,
                unit: nil
            )
            .frame(maxWidth: .infinity)
            Divider()
                .frame(height: 40)
            currentWeatherItem(
                titleKey: "humidity-title",
                value: "\((round(weather.humidity * 1000) * 100) / 1000)", // ex: 0.3456 → 34.6% 丸め誤差がでないように先に掛け算をする
                unit: "%"
            )
            .frame(maxWidth: .infinity)
            Divider()
                .frame(height: 40)
            currentWeatherItem(
                titleKey: "wind-title",
                value: "\(round(weather.windSpeed.value * 10) / 10)", // 少数第一位までの数で表す
                unit: weather.windSpeed.unit.symbol
            )
            .frame(maxWidth: .infinity)
        }
    }

    func currentWeatherItem(
        titleKey: LocalizedStringKey,
        description: String? = nil,
        value: String,
        unit: String?
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 12) {
                Text(titleKey, bundle: .module)
                    .font(.medium)
                VStack(alignment: .center, spacing: 0) {
                    if let description {
                        Text(description)
                            .font(.medium)
                    }
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(value)
                            .font(.medium)
                        if let unit {
                            Text(unit)
                                .font(.small)
                        }
                    }
                }
            }
        }
    }

    func hourlyWeatherDataItem(_ item: Model.HourWeather) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Text(item.date, format: Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)))
                .adaptiveFont(.normal, size: 12)
                .foregroundStyle(.gray)
            Image(systemName: item.symbolName)
                .font(.system(size: 18))
                .padding(4)
                .bold()

            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text("\(Int(item.temperature.value))")
                    .adaptiveFont(.normal, size: 16)
                Text("\(item.temperature.unit.symbol)")
                    .adaptiveFont(.normal, size: 12)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.cyan.opacity(0.1), in: Capsule())
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

#Preview {
    @Previewable @State var weatherDataModel = WeatherDataModel(
        weatherDataClient: MockWeatherDataClient(),
        locationManager: MockLocationManager(),
        aiClient: MockAIClient()
    )
    
    return WeatherDataView()
        .environment(weatherDataModel)
}
