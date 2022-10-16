import SwiftUI
import HealthKit

import Constant
import Extension
import Model
import StyleGuide

public struct HistoricalDataView: View {

    // Specific date data
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    @State private var stepCount: StepCount = .noData
    @State private var walkingSpeed: WalkingSpeed = .noData
    @State private var walkingStepLength: WalkingStepLength = .noData

    @AsyncState private var stepCounts: [Date: StepCount] = [:]
    private let calendar: Calendar = .current

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {

            SpecificDateDataView(
                selectedDate: selectedDate,
                stepCount: stepCount,
                walkingSpeed: walkingSpeed,
                walkingStepLength: walkingStepLength
            )
                .padding(.horizontal, 20)

                CalendarView(
                    stepCounts: stepCounts,
                    selectDateAction: { date in
                        selectedDate = date
                        loadSpecificDateData(date)
                    }
                ).asyncState(
                    _stepCounts,
                    initialContent: ProgressView()
                        .progressViewStyle(.circular),
                    loadingContent: ProgressView()
                        .progressViewStyle(.circular),
                    emptyContent: Text("データが存在しません"),
                    failureContent: Text("読み込みに失敗しました。")
                )
                .frame(height: 514)
        }
        .padding()
        .onAppear {
            if stepCounts.isEmpty {
                load()
                loadSpecificDateData(selectedDate)
            }
        }
    }
}

private extension HistoricalDataView {

    func loadSpecificDateData(_ date: Date) {
        Task.detached { @MainActor in
            async let stepCount = StepCount.load(for: date)
            async let walkingSpeed = WalkingSpeed.load(for: date)
            async let stepLength = WalkingStepLength.load(for: date)

            let datas = await (count: stepCount, speed: walkingSpeed, length: stepLength)
            self.stepCount = datas.count
            self.walkingSpeed = datas.speed
            self.walkingStepLength = datas.length
        }
    }

    func load() {
        let readTypes = Set(
            [
                HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
                HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!
            ]
        )

        HKHealthStore.shared.getRequestStatusForAuthorization(toShare: [], read: readTypes) { status, error in

            switch status {
            case .shouldRequest:
                print("shouldRequest")
            case .unnecessary:
                print("unnecessary")
            case .unknown:
                print("unknown")
            default:
                break
            }
        }

        Task {
            do {
                try await HKHealthStore.shared.requestAuthorization(toShare: [], read: readTypes)

                let calendar = Calendar.current
                // HealthKit is available from iOS 8(2014/9/17)
                let startDate = DateComponents(year: 2014, month: 9, day: 1, hour: 0, minute: 0, second: 0)
                let endDate = DateComponents(year: 2022, month: 10, day: 10, hour: 23, minute: 59, second: 59)

                await _stepCounts.fetch {
                    await StepCount.range(
                        start: calendar.date(from: startDate)!,
                        end: calendar.date(from: endDate)!
                    )
                }
            } catch {
                print(error)
            }
        }
    }
}

/*
 // preview crash
 #if DEBUG

 struct HistoricalDataView_Previews: PreviewProvider {
     static var previews: some View {
         HistoricalDataView()
     }
 }

 #endif
 */
