import CoreLocation
import SwiftUI
import WidgetKit

import Constant
import Extension
import Model

public struct HomeView: View {
    @AppStorage(
        UserDefaultsKey.dailyTargetSteps.rawValue,
        store: UserDefaults.app
    )
    var dailyTargetSteps: Int = 0

    @StateObject var stepCountData = StepCountData()
    @StateObject var distanceData = DistanceData()
    @StateObject var weatherData = WeatherData()

    @State private var inputGoal = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Text("Home View")

            Text("my goal is \(dailyTargetSteps)")
            TextField("Set Goal", value: $inputGoal, formatter: NumberFormatter())
            Button {
                dailyTargetSteps = inputGoal
                WidgetCenter.shared.reloadAllTimelines()
            } label: {
                Text("Save")
            }

            Text("stepCountData")
            switch stepCountData.phase {
            case .waiting:
                Text("waiting")
            case .success:
                Text("success")
                Text("\(stepCountData.todayStepCount!.number)")
                if stepCountData.todayStepCount!.number >= dailyTargetSteps {
                    Text("Goal is achieved")
                } else {
                    Text("Goal is not achieved")
                }
            case .failure(let error):
                Text("failure \(error.debugDescription)")
            }

            Text("distanceData")
            switch distanceData.phase {
            case .waiting:
                Text("waiting")
            case .success:
                Text("success")
                Text("\(distanceData.todayDistance!.distance)")
            case .failure(let error):
                Text("failure \(error.debugDescription)")
            }

            if let hourlyForecasts = weatherData.hourlyForecasts {
                ForEach(hourlyForecasts, id: \.self.date) { forecast in
                    HStack {
                        Text(forecast.date, format: Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)))
                        Image(systemName: forecast.symbolName)
                        Text(forecast.temperature.formatted(.measurement(width: .abbreviated, usage: .weather)))
                        Text(formattedPrecipitationChance(forecast.precipitationChance))
                    }
                }
            }
        }
        .padding()
        .onAppear {
            inputGoal = dailyTargetSteps
            weatherData.requestLocationAuth()
        }
    }
}

// TODO: デザイン当て込み時にリファクタ
func formattedPrecipitationChance(_ chance: Double) -> String {
    guard chance > 0 else { return "0%" }
    let percentage = Int(chance * 100)
    return "(\(percentage)%)"
}

#if DEBUG

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

#endif
