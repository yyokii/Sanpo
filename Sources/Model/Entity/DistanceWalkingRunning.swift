import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Distance of walking and running data（歩いた/走った距離） for a specific day
 */
public struct DistanceWalkingRunning: Codable {
    private static let logger = Logger(category: .model)

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
