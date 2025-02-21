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
    @EnvironmentObject private var workoutData: WorkoutData
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
                if let sunEvents = todayDataModel.mainSunEvents {
                    SunEventsCard(mainSunEvents: sunEvents)
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
        .background {
            Image(selectedCardImage, bundle: .module)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 70)
        }
        .navigationTitle("Sanpo")
        .refreshable {
            await weatherData.load()
            await stepCountData.loadTodayStepCount()
        }
        .onAppear {
            inputGoal = dailyTargetSteps
            weatherData.requestLocationAuth()
            Task {
                await todayDataModel.load()
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
    .environmentObject(WorkoutData())
    .environment(todayDataModel)
}
#endif
