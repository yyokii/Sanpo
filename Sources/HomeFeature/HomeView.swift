import SwiftUI
import WidgetKit

import Combine
import Constant
import Extension
import Model
import Service
import StyleGuide

public struct HomeView: View {
    @AppStorage(
        UserDefaultsKey.dailyTargetSteps.rawValue,
        store: UserDefaults.app
    )
    var dailyTargetSteps: Int = 3000

    @AppStorage(
        UserDefaultsKey.dailyTargetActiveEnergyBurned.rawValue,
        store: UserDefaults.app
    )
    var dailyTargetActiveEnergyBurned: Int = 2000

    @EnvironmentObject private var weatherData: WeatherData

    @StateObject var stepCountData = StepCountData()
    @StateObject var distanceData = DistanceData()

//    @State private var activeEnergyBurned: ActiveEnergyBurned = .noData // 定期的にloadする感じがいいかも
    @State private var inputGoal = 0
    @State private var showGoalSetting = false

    public init() {}

    public var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 32) {
                    todayDataView
                        .padding(.top, 20)
                        .padding(.horizontal, 10)

                    VStack(alignment: .leading, spacing: 20) {
                        Text("目標")
                            .adaptiveFont(.bold, size: 24)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(alignment: .center, spacing: 16) {
                            GoalView(title: "歩数", value: stepCountData.todayStepCount?.number ?? 0, unitText: "歩", goal: dailyTargetSteps)
//                            GoalView(title: "活動エネルギー量", value: activeEnergyBurned.energy, unitText: "kcal", goal: dailyTargetActiveEnergyBurned)
                        }
                    }

                    VStack(alignment: .center, spacing: 20) {
                        Text("天気")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .adaptiveFont(.bold, size: 24)

                        VStack(alignment: .center, spacing: 16) {
                            if let todayForecast = weatherData.todayForecast,
                               let mainSunEvents: SunEventsView.MainSunEvents = .init(from: todayForecast.sun) {
                                SunEventsView(
                                    now: Date(),
                                    sunEvents: mainSunEvents
                                )
                            }

                            HourlyWeatherDataView(hourlyForecasts: weatherData.hourlyForecasts)
                        }
                        .asyncState(weatherData.phase)
                        .padding(.horizontal, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .refreshable {
                await weatherData.load()
                await stepCountData.loadTodayStepCount()
            }
        }
        .navigationTitle("Sanpo")
        .onAppear {
            inputGoal = dailyTargetSteps
            weatherData.requestLocationAuth()
        }
        .onReceive(HealthKitAuthService.shared.$authStatus) { status in
            if let status,
               status == .unknown ||
               status == .shouldRequest {
                HealthKitAuthService.shared.requestAuthorization()
            }
        }
        .onReceive(HealthKitAuthService.shared.$isAuthRequestSuccess) { success in
            if success {
                Task.detached {
                    await stepCountData.loadTodayStepCount()
                }
            }
        }
        .sheet(isPresented: $showGoalSetting) {
            goalSettingView()
                .presentationDetents([.height(170)])
        }
    }
}

extension HomeView {
    var todayDataView: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 0) {
                VStack(spacing: 8) {
                    Text("\(stepCountData.todayStepCount?.number ?? 0)歩")
                        .adaptiveFont(.bold, size: 42)
                    Text("距離: \(distanceData.todayDistance?.distance ?? 0)m")
                        .adaptiveFont(.normal, size: 16)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background {
                Rectangle()
                    .fill(Color.adaptiveWhite)
                    .cornerRadius(20)
                    .adaptiveShadow()
            }

            RoundedIcon(symbolName: "figure.walk", iconColor: .hex(0xd65336))
                .padding(.top, 12)
                .padding(.leading, 12)
        }
    }

    func goalSettingView() -> some View {
        VStack(spacing: 16) {
            TextField("目標歩数", value: $inputGoal, formatter: NumberFormatter())
                .adaptiveFont(.bold, size: 40)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
            Button("設定する") {
                dailyTargetSteps = inputGoal
                WidgetCenter.shared.reloadAllTimelines()
            }
            .buttonStyle(ActionButtonStyle(size: .small))
        }
        .padding(20)
    }
}

#if DEBUG

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .environmentObject(WeatherData())
    }
}

#endif
