import CoreMotion
import Foundation
import HealthKit
import os.log

/**
 The data provider that loads StepCount data
 */
@MainActor
public class StepCountData: ObservableObject {
    let logger = Logger(subsystem: "com.yyokii.sanpo.StepCountData", category: "Model")

    @Published public var todayStepCount: StepCount?

    public enum Phase {
        case waiting
        case success
        case failure(Error?)
    }
    @Published public var phase: Phase = .waiting

    private let pedometer = CMPedometer()

    public init() {
        observeTodayStepCount()
    }

    func observeTodayStepCount() {
        phase = .waiting
        let now = Date()
        let todayStart: Date = Calendar.current.startOfDay(for: now)

        pedometer.startUpdates(from: todayStart) { [weak self] pedometerData, error in
            guard let self = self else {
                return
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.phase = .failure(error)
                }
                return
            }

            if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self.phase = .success
                    self.todayStepCount = .init(
                        date: now,
                        number: Int(truncating: pedometerData.numberOfSteps),
                        distance: Int(truncating: pedometerData.distance ?? 0)
                    )
                }
            } else {
                DispatchQueue.main.async {
                    self.phase = .failure(nil)
                }
            }
        }
    }

    // やっぱり step countでいいや
    static public func range(start: Date, end: Date) async -> [Date: StepCount] {
        if HKHealthStore.isHealthDataAvailable() {
            let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let now = Date()
            let todayStart: Date = Calendar.current.startOfDay(for: now)

            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: todayStart,
                intervalComponents: DateComponents(day: 1)
            )

            return await withCheckedContinuation { continuation in
                query.initialResultsHandler = { _, collection, error in
                    if let error = error {
                        print(error)
                        continuation.resume(returning: [:])
                        return
                    }

                    guard let statistics = collection?.statistics() else {
                        continuation.resume(returning: [:])
                        return
                    }

                    var dic: [Date: StepCount] = [:]
                    statistics.forEach({ data in
                        let number: Int = Int(
                            truncating: (data.sumQuantity()?.doubleValue(for: .count()) ?? 0) as NSNumber
                        )
                        let stepCount = StepCount(
                            date: data.startDate,
                            number: number,
                            distance: nil
                        )
                        dic[data.startDate] = stepCount
                    })

                    continuation.resume(returning: dic)
                }
                HKHealthStore.shared.execute(query)
            }
        } else {
            return [:]
        }
    }
}
