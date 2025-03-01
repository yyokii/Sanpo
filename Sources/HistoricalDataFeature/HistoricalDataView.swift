import SwiftUI
import HealthKit
import os.log

import Constant
import Extension
import Model
import StyleGuide

public struct HistoricalDataView: View {
    @Environment(MyDataModel.self) private var myDataModel

    @State private var specificDateViewData: SpecificDateDataView.ViewData?

    private let calendar: Calendar = .current
    private let logger = Logger(category: .view)

    public init() {}

    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            CalendarListView(stepCounts: myDataModel.stepCounts) { date in }
        }
//        .sheet(item: $specificDateViewData) { data in
//        }
        .navigationTitle("historical-data-title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension HistoricalDataView {
    enum DataSegment: Hashable, CaseIterable{
        case summary
        case calendar

        var title: String {
            switch self {
            case .summary:
                return String(localized: "summary", bundle: .module)
            case .calendar:
                return String(localized: "calendar", bundle: .module)
            }
        }
    }

    func loadSpecificDateData(_ date: Date) {
        Task { @MainActor in
            async let stepCount = StepCount.load(for: date)
            async let walkingSpeed = WalkingSpeed.load(for: date)
            async let stepLength = WalkingStepLength.load(for: date)

            guard let datas = try? await (count: stepCount, speed: walkingSpeed, length: stepLength) else {
                return
            }
            specificDateViewData = .init(
                selectedDate: date,
                stepCount: datas.count,
                walkingSpeed: datas.speed,
                walkingStepLength: datas.length
            )
        }
    }
}

#Preview {
    @Previewable @State var myDataModel = MyDataModel(healthDataClient: MockHealthDataClient())

    NavigationStack {
        HistoricalDataView()
            .environment(myDataModel)
            .onAppear {
                Task {
                    await  myDataModel.loadStepCounts()
                    try? await myDataModel.loadStepCountSummary()
                }
            }
    }
}
