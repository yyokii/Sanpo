import Foundation
import HealthKit

import Extension

/**
 Data Objects

 Steps data for a specific day
*/
public struct StepCount {
    public let date: Date
    public let number: Int
    public let distance: Int?

    public init (
        date: Date,
        number: Int,
        distance: Int?
    ) {
        self.date = date
        self.number = number
        self.distance = distance
    }

    static public func range(start: Date, end: Date) async -> [StepCount] {
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
                        continuation.resume(returning: [])
                        return
                    }

                    if let statistics = collection?.statistics() {
                        let datas: [StepCount] = statistics.map({ data in
                            let number: Int = Int(
                                truncating: (data.sumQuantity()?.doubleValue(for: .count()) ?? 0) as NSNumber
                            )
                            return StepCount(
                                date: data.startDate,
                                number: number,
                                distance: nil
                            )
                        })

                        continuation.resume(returning: datas)
                    } else {
                        continuation.resume(returning: [])
                        return
                    }
                }
                HKHealthStore.shared.execute(query)
            }
        } else {
            return []
        }
    }
}
