import SwiftUI
import WeatherKit
import Model
import SafariView
import StyleGuide
import Service

public struct WeatherDataView: View {
    @Environment(WeatherModel.self) private var weatherModel
    @State private var showWeatherKitLegalLink = false

    public init() {}

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                if let weatherWalkingAdvice = weatherModel.weatherWalkingAdvice {
                    VStack(alignment: .center, spacing: 0) {
                        Text(weatherWalkingAdvice.advice)
                            .font(.large)
                        Spacer(minLength: 8).fixedSize()
                        Text(weatherWalkingAdvice.recommendedTime)
                            .font(.medium)
                    }
                    .transition(.opacity)
                }
            }
            .frame(maxHeight: .infinity)
            .animation(.easeInOut(duration: 1), value: weatherModel.weatherWalkingAdvice)
            weather()
                .animation(.easeInOut(duration: 0.5), value: weatherModel.currentWeather)
                .animation(.easeInOut(duration: 0.5), value: weatherModel.mainSunEvents)
                .animation(.easeInOut(duration: 0.5), value: weatherModel.hourlyWeather)
            Spacer(minLength: 8).fixedSize()
        }
        .background {
            BlobBackgroundView()
        }
        .onAppear {
            Task {
                await weatherModel.load()
                try? await weatherModel.generateWalkingAdvice()
            }
        }
        .sheet(isPresented: $showWeatherKitLegalLink) {
            if let weatherDataAttribution = weatherModel.weatherDataAttribution {
                SafariView(url: weatherDataAttribution.url)
            }
        }
    }
}

private extension WeatherDataView {
    func weather() -> some View {
        VStack(alignment: .center, spacing: 0) {
            if let currentWeather = weatherModel.currentWeather,
               let sunEvents = weatherModel.mainSunEvents {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        currentWeatherTemperature(currentWeather)
                        Spacer(minLength: 16)
                        SunEventsCard(mainSunEvents: sunEvents)
                            .frame(width: 160)
                            .transition(.opacity)
                    }
                    Spacer(minLength: 16).fixedSize()
                    currentWeatherDetail(currentWeather)
                }
                .padding(.horizontal, 16)
                .transition(.opacity)
            }

            Spacer(minLength: 16).fixedSize()

            if let hourlyForecasts = weatherModel.hourlyWeather {
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
                .transition(.opacity)
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
            VStack(alignment: .center, spacing: 4) {
                Text(titleKey, bundle: .module)
                    .font(.medium)
                    .foregroundStyle(.gray)
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
    @Previewable @State var weatherDataModel = WeatherModel(
        weatherDataClient: MockWeatherDataClient(),
        locationManager: MockLocationManager(),
        aiClient: MockAIClient()
    )
    
    return WeatherDataView()
        .environment(weatherDataModel)
}
