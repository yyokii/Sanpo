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

    @State private var imageName = "demo"

    public init() {}

    public var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(alignment: .center, spacing: 20) {
                        todayDataView
                            .padding(.top, 20)
                        WeatherDataView(
                            currentWeather: .init(from: weatherData.currentWeather),
                            hourlyForecasts: weatherData.hourlyForecasts?
                                .forecast
                                .compactMap { .init(from: $0)
                                }
                        )
                        .asyncState(weatherData.phase)
                    }

                    /*
                     VStack(alignment: .leading, spacing: 20) {
                     Text("目標")
                     .adaptiveFont(.bold, size: 24)
                     .frame(maxWidth: .infinity, alignment: .leading)

                     HStack(alignment: .center, spacing: 16) {
                     GoalView(title: "歩数", value: stepCountData.todayStepCount?.number ?? 0, unitText: "歩", goal: dailyTargetSteps)
                     //                            GoalView(title: "活動エネルギー量", value: activeEnergyBurned.energy, unitText: "kcal", goal: dailyTargetActiveEnergyBurned)
                     }
                     }
                     */
                }
                .padding(.horizontal, 24)
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
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "figure.walk")
                    .adaptiveFont(.bold, size: 16)
                Text("Today")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .adaptiveFont(.bold, size: 16)
            }
            .padding(.horizontal, 16)

            VStack(alignment: .center, spacing: 16) {
                VStack(alignment: .center, spacing: 0) {
                    Text("\(stepCountData.todayStepCount?.number ?? 0)")
                        .adaptiveFont(.bold, size: 42)
                    Text("steps")
                        .adaptiveFont(.normal, size: 12)
                        .foregroundStyle(.gray)
                }
                Divider()
                LazyVGrid(
                    columns: Array(repeating: .init(.flexible(), spacing: 0, alignment: .top), count: 2),
                    spacing: 24
                ) {
                    detailDataItem(
                        title: "距離",
                        value: distanceData.todayDistance?.distance ?? 0,
                        unit: "m"
                    )
                    detailDataItem(
                        title: "昨日",
                        value: stepCountData.yesterdayStepCount?.number ?? 0,
                        unit: "steps"
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .foregroundStyle(checkIsLight(of: imageName) ? .black : .white)
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background {
            Image(imageName, bundle: .module)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .adaptiveShadow()
    }

    func detailDataItem(title: String, value: Int, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .adaptiveFont(.bold, size: 12)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(value)")
                    .adaptiveFont(.normal, size: 16)
                Text(unit)
                    .adaptiveFont(.normal, size: 12)
            }
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

    func checkIsLight(of imageName: String) -> Bool {
        let image = UIImage(named: imageName, in: .module, with: nil)
        let averageColor = image?.averageColor
        let relativeLuminance = averageColor?.relativeLuminance ?? 1
        return relativeLuminance > 0.7
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
