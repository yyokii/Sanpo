import CoreMotion
import Foundation
import HealthKit
import os.log

import Extension

/**
 Data Objects

 Steps data for a specific day
 */
public struct StepCount {
    private static let logger = Logger(subsystem: "com.yyokii.sanpo.StepCount", category: "Model")

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

    public static func todayDataOfCurrentDevice() -> StepCount {
        let now = Date()
        let todayStart: Date = Calendar.current.startOfDay(for: now)
        let pedometer = CMPedometer()

        var result: StepCount = .init(date: now, number: 0, distance: nil)
        pedometer.queryPedometerData(from: todayStart, to: now) { pedometerData, error in
            if let error = error {
                logger.debug("\(error.localizedDescription)")
                return
            }

            if let pedometerData = pedometerData {
                result = StepCount(
                    date: now,
                    number: Int(truncating: pedometerData.numberOfSteps),
                    distance: Int(truncating: pedometerData.distance ?? 0)
                )
            }
        }
        return result
    }
}
