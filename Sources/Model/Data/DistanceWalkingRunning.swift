import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Data Objects

 Steps data for a specific day
 */
public struct DistanceWalkingRunning: Codable {
    private static let logger = Logger(subsystem: "com.yyokii.sanpo", category: "Model: DistanceWalkingRunning")

    public let date: Date
    public let distance: Int

    public init (
        date: Date,
        distance: Int
    ) {
        self.date = date
        self.distance = distance
    }
}

extension DistanceWalkingRunning {
    public static let noData: DistanceWalkingRunning = .init(date: Date(), distance: 0)

    public static func range(start: Date, end: Date) async -> [Date: DistanceWalkingRunning] {
        if HKHealthStore.isHealthDataAvailable() {
            let type = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
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
                        logger.debug("\(error.localizedDescription)")
                        continuation.resume(returning: [:])
                        return
                    }

                    guard let statistics = collection?.statistics() else {
                        continuation.resume(returning: [:])
                        return
                    }

                    var dic: [Date: DistanceWalkingRunning] = [:]
                    statistics.forEach({ data in
                        let distance: Int = Int(
                            truncating: (data.sumQuantity()?.doubleValue(for: .meter()) ?? 0) as NSNumber
                        )
                        let distanceWalkingRunning = DistanceWalkingRunning(
                            date: data.startDate,
                            distance: distance
                        )
                        dic[data.startDate] = distanceWalkingRunning
                    })

                    continuation.resume(returning: dic)
                }
                HKHealthStore.shared.execute(query)
            }
        } else {
            return [:]
        }
    }

    public static func today() async -> DistanceWalkingRunning {
        if HKHealthStore.isHealthDataAvailable() {
            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: now,
                options: .strictStartDate
            )

            return await withCheckedContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepsQuantityType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in

                    if let error = error {
                        logger.debug("\(error.localizedDescription)")
                        continuation.resume(returning: DistanceWalkingRunning.noData)
                        return
                    }

                    guard let statistics = statistics, let sum = statistics.sumQuantity() else {
                        continuation.resume(returning: DistanceWalkingRunning.noData)
                        return
                    }

                    let distance: Int = Int(
                        truncating: (sum.doubleValue(for: .meter())) as NSNumber
                    )

                    continuation.resume(returning:
                            .init(
                                date: now,
                                distance: distance
                            )
                    )
                }

                HKHealthStore.shared.execute(query)
            }
        } else {
            return .noData
        }
    }
}
