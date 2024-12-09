import SwiftUI
import WeatherKit

import Model
import StyleGuide

public struct WeatherDataView: View {
    @State var weatherAttribution: WeatherAttribution?
    @State var showWeatherKitLegalLink = false

    private let weatherService = WeatherService()
    let currentWeather: Model.CurrentWeather?
    let hourlyForecasts: [Model.HourWeather]?

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "sun.haze")
                    .adaptiveFont(.bold, size: 16)
                Text("Weather")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveFont(.bold, size: 16)
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 28).fixedSize()

            if let currentWeather {
                VStack(alignment: .leading, spacing: 16) {
                    Text("current-weather-title", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .adaptiveFont(.bold, size: 12)
                        .foregroundStyle(.gray)
                    currentWeatherItem(currentWeather)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 16)
            }

            Spacer(minLength: 28).fixedSize()

            if let hourlyForecasts {
                VStack(alignment: .leading, spacing: 16) {
                    Text("hourly-weather-title", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .adaptiveFont(.bold, size: 12)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal) {
                        HStack(alignment: .center, spacing: 10) {
                            ForEach(hourlyForecasts.prefix(12), id: \.date) { forecast in
                                hourlyWeatherDataItem(forecast)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .scrollIndicators(.hidden)
                }
            }

            Spacer(minLength: 16).fixedSize()

            if let weatherAttribution {
                HStack {
                    Spacer()
                    AsyncImage(
                        url: weatherAttribution.combinedMarkLightURL
                    ) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                    } placeholder: {
                        ProgressView()
                    }
                    Button("Link") {
                        showWeatherKitLegalLink.toggle()
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background {
            Rectangle()
                .fill(Color.adaptiveWhite)
                .cornerRadius(20)
                .adaptiveShadow()
        }
        .task {
            weatherAttribution = try? await weatherService.attribution
        }
        .sheet(isPresented: $showWeatherKitLegalLink) {
            if let weatherAttribution {
                SafariView(url: weatherAttribution.legalPageURL)
            }
        }
    }
}

private extension WeatherDataView {
    func currentWeatherItem(_ weather: Model.CurrentWeather) -> some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 4) {
                Image(systemName: weather.symbolName)
                    .font(.system(size: 24))
                    .padding(4)
                    .bold()
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text("\(Int(weather.temperature.value))")
                        .adaptiveFont(.normal, size: 32)
                    Text("\(weather.temperature.unit.symbol)")
                        .adaptiveFont(.normal, size: 28)
                }
            }

            Spacer(minLength: 24).fixedSize()

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
                    description: "\(weather.windDirection.description)",
                    value: "\(round(weather.windSpeed.value * 10) / 10)", // 少数第一位までの数で表す
                    unit: weather.windSpeed.unit.symbol
                )
                .frame(maxWidth: .infinity)
            }
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
                    .adaptiveFont(.bold, size: 12)
                VStack(alignment: .center, spacing: 0) {
                    if let description {
                        Text(description)
                            .adaptiveFont(.normal, size: 12)
                    }
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(value)
                            .adaptiveFont(.normal, size: 12)
                        if let unit {
                            Text(unit)
                                .adaptiveFont(.normal, size: 10)
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
    return WeatherDataView(
        currentWeather: .mock,
        hourlyForecasts: HourWeather.mock
    )
    .padding(.horizontal, 30)
}
