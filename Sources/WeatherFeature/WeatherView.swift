//import Combine
//import Constant
//import Extension
//import Model
//import Service
//import StyleGuide
//import SwiftUI
//import WidgetKit
//
//public struct WeatherView: View {
//    @AppStorage(
//        UserDefaultsKey.dailyTargetSteps.rawValue
//    )
//    private var dailyTargetSteps: Int = 3000
//
//    @AppStorage(
//        UserDefaultsKey.dailyTargetActiveEnergyBurned.rawValue
//    )
//    private var dailyTargetActiveEnergyBurned: Int = 2000
//
//    @AppStorage(UserDefaultsKey.cardBackgroundImageName.rawValue)
//    private var selectedCardImage = "cliff-sea-1"
//
//    @EnvironmentObject private var weatherData: WeatherData
//    @Environment(TodayDataModel.self) private var todayDataModel
//
//    @StateObject var stepCountData = StepCountData()
//    @StateObject var distanceData = DistanceData()
//
//    // @State private var activeEnergyBurned: ActiveEnergyBurned = .noData // 定期的にloadする感じがいいかも
//    @State private var inputGoal = 0
//    @State private var showGoalSetting = false
//
//    @State private var isSelectCardImageViewPresented = false
//
//    let todayCardViewHeight: CGFloat = 270
//
//    public init() {}
//
//    public var body: some View {
//        ScrollView {
//            VStack(alignment: .center, spacing: 0) {
//                titleRow("Weather")
//                    .padding(.horizontal, 12)
//                Spacer(minLength: 12).fixedSize()
//                if let sunEvents = todayDataModel.mainSunEvents {
//                    SunEventsCard(mainSunEvents: sunEvents)
//                        .padding(.horizontal, 24)
//                }
//                Spacer(minLength: 20).fixedSize()
//                WeatherDataView(
//                    currentWeather: weatherData.currentWeather,
//                    hourlyForecasts: weatherData.hourlyForecasts
//                )
//                .asyncState(weatherData.phase)
//                .padding(.horizontal, 24)
//
//            }
//            .padding(.bottom, 16)
//        }
//        .background {
//            Color(uiColor: .secondarySystemBackground)
//                .ignoresSafeArea()
//        }
//        .navigationTitle("Weather")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            weatherData.requestLocationAuth()
//            Task {
//                await todayDataModel.load()
//                try await todayDataModel.updateCurrentStepGoalStreak(goal: dailyTargetSteps)
//            }
//        }
//    }
//}
//
//extension WeatherView {
//    func titleRow(_ title: String) -> some View {
//        Text(title)
//            .font(.large)
//            .bold()
//            .frame(maxWidth: .infinity, alignment: .leading)
//    }
//
//    func goalSettingView() -> some View {
//        VStack(spacing: 16) {
//            TextField("目標歩数", value: $inputGoal, formatter: NumberFormatter())
//                .adaptiveFont(.bold, size: 40)
//                .lineLimit(1)
//                .multilineTextAlignment(.trailing)
//            Button("設定する") {
//                dailyTargetSteps = inputGoal
//                WidgetCenter.shared.reloadAllTimelines()
//            }
//            .buttonStyle(ActionButtonStyle(size: .small))
//        }
//        .padding(20)
//    }
//}
//
//#if DEBUG
//
//#Preview {
//    @Previewable @State var todayDataModel = TodayDataModel(
//        healthDataClient: MockHealthDataClient(),
//        weatherDataClient: MockWeatherDataClient(),
//        locationManager: MockLocationManager()
//    )
//
//    NavigationStack {
//        HomeView()
//    }
//    .onAppear {
//        Task {
//          try? await todayDataModel.load()
//        }
//    }
//    .environmentObject(WeatherData.preview)
//    .environment(todayDataModel)
//}
//#endif
