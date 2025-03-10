import Combine
import Constant
import Extension
import Model
import Service
import StyleGuide
import SwiftUI
import WidgetKit

public struct HomeView: View {
    @AppStorage(
        UserDefaultsKey.dailyTargetSteps.rawValue
    )
    private var dailyTargetSteps: Int = 3000

    @AppStorage(
        UserDefaultsKey.dailyTargetActiveEnergyBurned.rawValue
    )
    private var dailyTargetActiveEnergyBurned: Int = 2000

    @AppStorage(UserDefaultsKey.cardBackgroundImageName.rawValue)
    private var selectedCardImage = "cliff-sea-1"

    @EnvironmentObject private var weatherData: WeatherData
    @Environment(TodayDataModel.self) private var todayDataModel

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
                Image(selectedCardImage, bundle: .module)
                    .resizable()
                    .frame(height: 320)
                    .scaledToFill()
                    .blur(radius: 40)
                    .overlay {
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
                        .padding(.horizontal, 24)
                    }
                Spacer(minLength: 20).fixedSize()
                DailyStepGoalView(
                    todaySteps: todayDataModel.todayStepCount.number,
                    goal: dailyTargetSteps,
                    goalAchievementStatus: .init(
                        isTodayAchieved: todayDataModel.todayStepCount.number >= dailyTargetSteps,
                        consecutiveDays: todayDataModel.goalStreak
                    )
                )
                .padding(.horizontal, 24)
                Spacer(minLength: 20).fixedSize()
                if let sunEvents = todayDataModel.mainSunEvents {
                    SunEventsCard(mainSunEvents: sunEvents)
                        .padding(.horizontal, 24)
                }
                Spacer(minLength: 20).fixedSize()
                WeatherDataView(
                    currentWeather: weatherData.currentWeather,
                    hourlyForecasts: weatherData.hourlyForecasts
                )
                .asyncState(weatherData.phase)
                .padding(.horizontal, 24)

            }
            .padding(.bottom, 16)
        }
        .navigationTitle("Sanpo")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await weatherData.load()
            await stepCountData.loadTodayStepCount()
        }
        .onAppear {
            inputGoal = dailyTargetSteps
            weatherData.requestLocationAuth()
            Task {
                await todayDataModel.load()
                try await todayDataModel.updateCurrentStepGoalStreak(goal: dailyTargetSteps)
            }
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
}

#if DEBUG

#Preview {
    @Previewable @State var todayDataModel = TodayDataModel(
        healthDataClient: MockHealthDataClient(),
        weatherDataClient: MockWeatherDataClient(),
        locationManager: MockLocationManager()
    )

    NavigationStack {
        HomeView()
    }
    .onAppear {
        Task {
          try? await todayDataModel.load()
        }
    }
    .environmentObject(WeatherData.preview)
    .environment(todayDataModel)
}
#endif
