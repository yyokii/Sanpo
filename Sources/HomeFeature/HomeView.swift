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
    var dailyTargetSteps: Int = 0

    @StateObject var stepCountData = StepCountData()
    @StateObject var distanceData = DistanceData()
    @StateObject var weatherData = WeatherData()

    @State private var inputGoal = 0
    @State private var showGoalSetting = false

    public init() {}

    public var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("今日のデータ")
                            .adaptiveFont(.bold, size: 24)

                        todayGoalView

                        todayDataView
                            .padding(.horizontal, 10)
                    }
                    .padding(.top, 32)

                    VStack(alignment: .center, spacing: 20) {
                        Text("天気")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .adaptiveFont(.bold, size: 24)

                        HourlyWeatherDataView(hourlyForecasts: weatherData.hourlyForecasts)
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
            .padding(.top, 4)
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
        ZStack {
            Rectangle()
                .fill(Color.adaptiveWhite)
                .cornerRadius(20)
                .adaptiveShadow()

            VStack(spacing: 8) {
                Text("\(stepCountData.todayStepCount?.number ?? 0)歩")
                    .adaptiveFont(.bold, size: 42)

                Text("距離: \(distanceData.todayDistance?.distance ?? 0)m")
                    .adaptiveFont(.normal, size: 16)
            }
        }
        .frame(height: 130)
    }

    var todayGoalView: some View {
        Button {
            showGoalSetting = true
        } label: {
            HStack(alignment: .center) {
                Text("目標: \(dailyTargetSteps)歩")
                    .adaptiveFont(.normal, size: 16)

                Image(systemName: "square.and.pencil")
                    .padding(.bottom, 2)
            }
        }
        .foregroundColor(.adaptiveBlack)
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
    }
}

#endif
