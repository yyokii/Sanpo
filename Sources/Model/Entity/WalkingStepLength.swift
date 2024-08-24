import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Walking speed length data（歩幅）
 */
public struct WalkingStepLength: Codable {
    private static let logger = Logger(category: .model)

    public let start: Date
    public let end: Date
    public let length: Float

    public init (
        start: Date,
        end: Date,
        length: Float
    ) {
        self.start = start
        self.end = end
        self.length = length
    }
}

extension WalkingStepLength {
    public static let noData: WalkingStepLength = .init(start: Date(), end: Date(), length: 0)

    public static func load(for date: Date) async throws -> WalkingStepLength {
        let walkingStepLengthQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.endOfDay(for: date)
        return try await load(start: startOfDay, end: endOfDay)
    }

    public static func load(start: Date, end: Date) async throws -> WalkingStepLength {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let walkingStepLengthQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: walkingStepLengthQuantityType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in

                if let error = error {
                    logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = statistics, let sum = statistics.averageQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let length: Float = Float(
                    truncating: (sum.doubleValue(for: .meter())) as NSNumber
                )
                continuation.resume(returning:
                        .init(
                            start: start,
                            end: end,
                            length: length
                        )
                )
            }
            HKHealthStore.shared.execute(query)
        }
    }
}
