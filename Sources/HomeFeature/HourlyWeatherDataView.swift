import SwiftUI
import WeatherKit

import Model
import StyleGuide

public struct HourlyWeatherDataView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State var weatherAttribution: WeatherAttribution?
    @State var showWeatherKitLegalLink = false

    private let weatherService = WeatherService()
    let hourlyForecasts: Forecast<HourWeather>?

    public var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.adaptiveWhite)
                .cornerRadius(20)
                .adaptiveShadow()

            VStack(alignment: .leading, spacing: 38) {
                Text("1時間ごとの天気")
                    .adaptiveFont(.bold, size: 20)

                VStack(spacing: 16) {
                    weatherColumnTitle

                    if let hourlyForecasts {
                        ForEach(hourlyForecasts[0..<6], id: \.self.date) { forecast in
                            weatherDataRow(
                                date: forecast.date,
                                weatherIconName: forecast.symbolName,
                                temperature: forecast.temperature,
                                precipitationChance: forecast.precipitationChance
                            )
                        }
                        .padding(.bottom, 8)
                    }

                    if let weatherAttribution {
                        HStack {
                            Spacer()
                            AsyncImage(
                                url: colorScheme == .light ?
                                weatherAttribution.combinedMarkLightURL
                                : weatherAttribution.combinedMarkDarkURL
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
                    }
                }
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 18)
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
    var weatherColumnTitle: some View {
        HStack {
            Text("時間")
                .adaptiveFont(.normal, size: 12)
            Spacer()
            Text("天気")
                .adaptiveFont(.normal, size: 12)
            Spacer()
            Text("降水確率")
                .adaptiveFont(.normal, size: 12)
        }
        .foregroundColor(.gray)
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
