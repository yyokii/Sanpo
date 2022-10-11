import SwiftUI
import HealthKit

import Constant
import Model
import StyleGuide

public struct HistoricalDataView: View {
    @State private var stepCounts: [Date: StepCount] = [:]
    private let calendar: Calendar = .current

    @State private var walkingSpeed: WalkingSpeed = .noData
    @State private var walkingStepLength: WalkingStepLength = .noData

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {

            specificDateDataView

            CalendarView(
                stepCounts: stepCounts,
                selectDateAction: { date in
                    loadSpecificDateData(date)
                }
            )
        }
        .padding()
        .onAppear {
            load()
        }
    }
}

private extension HistoricalDataView {

    var specificDateDataView: some View {
        ZStack {
            Rectangle()
                .fill(Color.adaptiveWhite)
                .cornerRadius(20)
                .adaptiveShadow()

            VStack(spacing: 24) {

                Text("aaaのデータ")

                VStack {
                    Text("\(walkingSpeed.speed)")
                    Text("\(walkingStepLength.length)")
                }
            }
        }
        .frame(height: 180)
    }

    func loadSpecificDateData(_ date: Date) {
        Task.detached { @MainActor in
            let speed = await WalkingSpeed.load(for: date)
            let stepLength = await WalkingStepLength.load(for: date)

            walkingSpeed = speed
            walkingStepLength = stepLength
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
                let startDate = DateComponents(year: 2021, month: 8, day: 23, hour: 0, minute: 0, second: 0)
                let endDate = DateComponents(year: 2022, month: 9, day: 10, hour: 23, minute: 59, second: 59)

                let dic: [Date: StepCount] = await StepCount.range(
                    start: calendar.date(from: startDate)!,
                    end: calendar.date(from: endDate)!
                )
                self.stepCounts = dic

            } catch {
                print(error)
            }
        }
    }
}

// preview crash
//
//#if DEBUG
//
//struct HistoricalDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoricalDataView()
//    }
//}
//
//#endif
