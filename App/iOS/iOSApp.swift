import SwiftUI

import Constant
import MainTab
import Model

@main
struct iOSApp: App {
    @StateObject var weatherData = WeatherData()
    @StateObject var workoutData = WorkoutData()

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
        }
    }
}
