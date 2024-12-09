import SwiftUI
import HealthKit
import os.log

import Constant
import Extension
import Model
import StyleGuide

public struct HistoricalDataView: View {
    private let logger = Logger(category: .view)

    @State var specificDateViewData: SpecificDateDataView.ViewData?

    @AsyncState private var stepCounts: [Date: StepCount] = [:]
    private let calendar: Calendar = .current

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Text("歩数")
                .adaptiveFont(.bold, size: 33)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            Spacer(minLength: 16).fixedSize()

            CalendarView(
                stepCounts: stepCounts,
                selectDateAction: { date in
                    loadSpecificDateData(date)
                }
            )
//            .asyncState(
//                _stepCounts,
//                initialContent: ProgressView()
//                    .progressViewStyle(.circular),
//                loadingContent: ProgressView()
//                    .progressViewStyle(.circular),
//                emptyContent: Text("データが存在しません"),
//                failureContent: Text("読み込みに失敗しました。")
//            )

            // シートで出すので良さそう
            //            if let selectedDate {
            //                SpecificDateDataView(
            //                    selectedDate: selectedDate,
            //                    stepCount: stepCount,
            //                    walkingSpeed: walkingSpeed,
            //                    walkingStepLength: walkingStepLength
            //                )
            //                .padding(.horizontal, 20)
            //            }
            .frame(height: 514)
        }
        .onAppear {
            if stepCounts.isEmpty {
                load()
            }
        }
        .sheet(item: $specificDateViewData) { data in
            
        }
    }
}

private extension HistoricalDataView {

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

    func load() {
        Task {
            let calendar = Calendar.current
            // HealthKit is available from iOS 8(2014/9/17)
            let startDate = DateComponents(year: 2014, month: 9, day: 1, hour: 0, minute: 0, second: 0)

            await _stepCounts.fetch {
                try await StepCount.range(
                    start: calendar.date(from: startDate)!,
                    end: Date()
                )
            }
        }
    }
}

 // preview crash
 #if DEBUG

 struct HistoricalDataView_Previews: PreviewProvider {
     static var previews: some View {
         HistoricalDataView()
     }
 }

 #endif
