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
    private var dailyTargetSteps: Int = 3000

    @AppStorage(
        UserDefaultsKey.dailyTargetActiveEnergyBurned.rawValue,
        store: UserDefaults.app
    )
    private var dailyTargetActiveEnergyBurned: Int = 2000

    @AppStorage(UserDefaultsKey.cardBackgroundImageName.rawValue)
    private var selectedCardImage = ""

    @EnvironmentObject private var weatherData: WeatherData
    @EnvironmentObject private var workoutData: WorkoutData

    @StateObject var stepCountData = StepCountData()
    @StateObject var distanceData = DistanceData()

    // @State private var activeEnergyBurned: ActiveEnergyBurned = .noData // 定期的にloadする感じがいいかも
    @State private var inputGoal = 0
    @State private var showGoalSetting = false

    @State private var isSelectCardImageViewPresented = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                Spacer(minLength: 20).fixedSize()
                Button {
                    isSelectCardImageViewPresented = true
                } label: {
                    TodayDataCard(
                        stepCount: stepCountData.todayStepCount?.number ?? 0,
                        yesterdayStepCount: stepCountData.yesterdayStepCount?.number ?? 0,
                        distance: distanceData.todayDistance?.distance ?? 0,
                        backgroundImageName: selectedCardImage
                    )
                }
                Spacer(minLength: 20).fixedSize()
                WeatherDataView(
                    currentWeather: weatherData.currentWeather,
                    hourlyForecasts: weatherData.hourlyForecasts
                )
                .asyncState(weatherData.phase)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .refreshable {
            await weatherData.load()
            await stepCountData.loadTodayStepCount()
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
                Task {
                    await stepCountData.loadTodayStepCount()
                }
            }
        }
        .sheet(isPresented: $showGoalSetting) {
            goalSettingView()
                .presentationDetents([.height(170)])
        }
        .navigationDestination(isPresented: $isSelectCardImageViewPresented) {
            SelectCardImageView()
        }
    }
}

extension HomeView {
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
        NavigationStack {
            HomeView()
        }
        .environmentObject(WeatherData.preview)
        .environmentObject(WorkoutData())
    }
}

#endif
