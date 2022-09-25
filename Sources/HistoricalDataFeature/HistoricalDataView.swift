import SwiftUI
import HealthKit

import Model

public struct HistoricalDataView: View {
    @EnvironmentObject var myGoalStore: MyGoalStore
    @State var stepCounts: [Date: StepCount] = [:]
    private let calendar: Calendar = .current

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Text("HistoricalData View")

            CalendarView(
                stepCounts: stepCounts,
                myGoal: myGoalStore,
                selectDateAction: { date in
                    print(date)
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

    func load() {
        let readTypes = Set(
            [
                HKQuantityType.quantityType(forIdentifier: .stepCount)!
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
