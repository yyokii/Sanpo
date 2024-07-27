import SwiftUI
import WeatherKit

import Model
import StyleGuide

public struct HourlyWeatherDataView: View {
    @State var weatherAttribution: WeatherAttribution?
    @State var showWeatherKitLegalLink = false

    private let weatherService = WeatherService()
    let currentWeather: CurrentWeather?
    let hourlyForecasts: [HourWeather]?

    public var body: some View {
        VStack(alignment: .leading, spacing: 38) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "sun.haze")
                    .adaptiveFont(.bold, size: 16)
                Text("Weather")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveFont(.bold, size: 16)
            }
            .padding(.horizontal, 16)

            if let currentWeather {
                currentWeatherItem(currentWeather)
                    .padding(.horizontal, 24)
            }

            if let hourlyForecasts {
                ScrollView(.horizontal) {
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(hourlyForecasts, id: \.date) { forecast in
                            weatherDataItem(forecast)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, 8)
            }

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

extension HourlyWeatherDataView {
    func currentWeatherItem(_ weather: CurrentWeather) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text("\(Int(weather.temperature.value))")
                        .adaptiveFont(.normal, size: 32)
                    Text("\(weather.temperature.unit.symbol)")
                        .adaptiveFont(.normal, size: 28)
                }
                Image(systemName: weather.symbolName)
                    .font(.system(size: 18))
                    .padding(4)
                    .bold()
            }

            LazyVGrid(
                columns: Array(repeating: .init(.flexible(), spacing: 0, alignment: .top), count: 2),
                spacing: 24
            ) {
                currentWeatherItem(titleKey: "uv-title", value: weather.uvIndexCategory.label, unit: nil)
                currentWeatherItem(titleKey: "humidity-title", value: "\(weather.humidity * 100)", unit: "%")
                currentWeatherItem(
                    titleKey: "wind-title",
                    description: "\(weather.windDirection.description)",
                    value: "\(weather.windSpeed.value)",
                    unit: weather.windSpeed.unit.symbol
                )
            }
            .frame(maxWidth: .infinity)
        }
    }

    func currentWeatherItem(
        titleKey: LocalizedStringKey,
        description: String? = nil,
        value: String,
        unit: String?
    ) -> some View {
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

    func weatherDataItem(_ item: HourWeather) -> some View {
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
        .background(.ultraThinMaterial, in: Capsule())
    }

    func weatherDataRow(
        date: Date,
        weatherIconName: String,
        temperature: Measurement<UnitTemperature>,
        precipitationChance: Double
    ) -> some View {
        HStack {
            Text(date, format: Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)).minute())
                .adaptiveFont(.normal, size: 18)
            Spacer()
            HStack {
                Image(systemName: weatherIconName)
                Text(temperature.formatted(.measurement(width: .abbreviated, usage: .weather)))
                    .adaptiveFont(.normal, size: 18)
                    .frame(width: 90, alignment: .leading)
            }
            Spacer()
            Text(formattedPrecipitationChance(precipitationChance))
                .adaptiveFont(.normal, size: 18)

        }
    }

    func formattedPrecipitationChance(_ chance: Double) -> String {
        guard chance > 0 else { return "0%" }
        let percentage = Int(chance * 100)
        return "\(percentage)%"
    }
}

#Preview {
    let now: Date = .now

    return HourlyWeatherDataView(
        currentWeather: .init(
            date: now,
            symbolName: "sun.max",
            humidity: 0.34,
            temperature: .ValueType(value: 35.4, unit: .celsius),
            uvIndexCategory: .moderate,
            windSpeed: .ValueType(value: 12, unit: .kilometersPerHour),
            windDirection: .north
        ),
        hourlyForecasts: [
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
    )
    .padding(.horizontal, 24)
}
