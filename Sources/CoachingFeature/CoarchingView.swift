import SwiftUI
import WeatherKit
import Model
import SafariView
import StyleGuide
import Service

public struct CoachingView: View {
    @Environment(CoachingModel.self) private var coachingModel

    public init() {}

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {

            Text(verbatim: "hi")

            Text(verbatim: "bottom")
        }
        .onAppear {
        }
    }
}

private extension CoachingView {

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
