import Constant
import MainTab
import Model
import Service
import SwiftUI

@main
struct iOSApp: App {
    @StateObject var weatherData = WeatherData()
    @StateObject var workoutData = WorkoutData()

    @State private var myDataModel = MyDataModel(healthDataClient: HealthDataClient.shared)
    @State private var todayDataModel = TodayDataModel(
        healthDataClient: HealthDataClient.shared,
        weatherDataClient: WeatherDataClient.shared,
        locationManager: LocationManager.shared
    )
    @State private var weatherModel = WeatherModel(
        weatherDataClient: WeatherDataClient.shared,
        locationManager: LocationManager.shared,
        aiClient: AIClient.shared
    )

    init() {
        let userDefaults = UserDefaults(suiteName: UserDefaultsSuitName.app.rawValue)!

        userDefaults.register(
            defaults: [UserDefaultsKey.dailyTargetSteps.rawValue: 8000]
        )
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(weatherData)
                .environmentObject(workoutData)
                .environment(myDataModel)
                .environment(todayDataModel)
                .environment(weatherModel)
                .onAppear {
                    Task {
                        await myDataModel.loadStepCounts()
                        try? await myDataModel.loadStepCountSummary()
                    }
                }
                .tint(.black)
        }
    }
}
