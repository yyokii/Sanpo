import Constant
import Extension
import HistoricalDataFeature
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

    // TODO: 歩数データは定期的にloadする
    @Environment(TodayDataModel.self) private var todayDataModel

    @State private var inputGoal = 0
    @State private var showGoalSetting = false

    @State private var isSelectCardImageViewPresented = false
    @State private var isCalendarPresented = false

    let todayCardViewHeight: CGFloat = 270

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                Image(selectedCardImage, bundle: .module)
                    .resizable()
                    .frame(height: todayCardViewHeight)
                    .scaledToFill()
                    .blur(radius: 40)
                    .overlay {
                        Button {
                            isSelectCardImageViewPresented = true
                        } label: {
                            TodayDataCard(
                                stepCount: todayDataModel.todayStepCount.number,
                                yesterdayStepCount: todayDataModel.yesterdayStepCount.number,
                                distance: todayDataModel.todayDistance.distance,
                                backgroundImageName: selectedCardImage
                            )
                            .frame(height: todayCardViewHeight)
                        }
                        .padding(.horizontal, 24)
                    }
                Spacer(minLength: 32).fixedSize()
                titleRow("Goal")
                    .padding(.horizontal, 12)
                Spacer(minLength: 12).fixedSize()
                DailyStepGoalView(
                    todaySteps: todayDataModel.todayStepCount.number,
                    goal: dailyTargetSteps,
                    goalAchievementStatus: .init(
                        isTodayAchieved: todayDataModel.todayStepCount.number >= dailyTargetSteps,
                        consecutiveDays: todayDataModel.goalStreak
                    )
                )
                .padding(.horizontal, 24)
                Spacer(minLength: 24).fixedSize()
            }
            .padding(.bottom, 16)
        }
        .background {
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea()
        }
        .navigationTitle("Sanpo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isCalendarPresented = true
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(.black)
                        .font(.medium)
                }
            }
        }
        // TODO: ヘルスデータ権限のチェックエラー時やそれが変わった時のケアをする
        .refreshable {
            await todayDataModel.load()
        }
        .onAppear {
            inputGoal = dailyTargetSteps
            Task {
                await todayDataModel.load()
                try await todayDataModel.updateCurrentStepGoalStreak(goal: dailyTargetSteps)
            }
        }
        .sheet(isPresented: $showGoalSetting) {
            goalSettingView()
                .presentationDetents([.height(170)])
        }
        .sheet(isPresented: $isCalendarPresented) {
            NavigationStack {
                HistoricalDataView()
            }
        }
        .navigationDestination(isPresented: $isSelectCardImageViewPresented) {
            SelectCardImageView()
        }
    }
}

extension HomeView {
    func titleRow(_ title: String) -> some View {
        Text(title)
            .font(.large)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview {
    @Previewable @State var todayDataModel = TodayDataModel(
        healthDataClient: MockHealthDataClient(),
        weatherDataClient: MockWeatherDataClient(),
        locationManager: MockLocationManager()
    )
    @Previewable @State var myDataModel = MyDataModel(
        healthDataClient: MockHealthDataClient()
    )

    NavigationStack {
        HomeView()
    }
    .onAppear {
        Task {
            try? await todayDataModel.load()
            await  myDataModel.loadStepCounts()
            try? await myDataModel.loadStepCountSummary()
        }
    }
    .environment(todayDataModel)
    .environment(myDataModel)
}
#endif
