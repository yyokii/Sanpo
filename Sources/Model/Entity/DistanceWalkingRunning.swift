import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Distance of walking and running data（歩いた/走った距離）
 */
public struct DistanceWalkingRunning: Codable {
    private static let logger = Logger(category: .model)

    public let start: Date
    public let end: Date
    public let distance: Int

    public init (
        start: Date,
        end: Date,
        distance: Int
    ) {
        self.start = start
        self.end = end
        self.distance = distance
    }
}

extension DistanceWalkingRunning {
    var sampleData: HKQuantitySample {
        .init(
            type: .init(.distanceWalkingRunning),
            quantity: .init(
                unit: .meter(),
                doubleValue: Double(self.distance)),
            start: self.start,
            end: self.end
        )
    }

    public static let noData: DistanceWalkingRunning = .init(start: Date(), end: Date(), distance: 0)

    public static func today() async throws -> DistanceWalkingRunning {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        return try await load(start: startOfDay, end: now)
    }

    public static func load(start: Date, end: Date) async throws -> DistanceWalkingRunning {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsQuantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in

                if let error = error {
                    logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = statistics, let sum = statistics.sumQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let distance: Int = Int(
                    truncating: (sum.doubleValue(for: .meter())) as NSNumber
                )

                continuation.resume(returning:
                        .init(
                            start: start,
                            end: end,
                            distance: distance
                        )
                )
            }

            HKHealthStore.shared.execute(query)
        }
    }
}
