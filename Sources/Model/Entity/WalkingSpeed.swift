import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Walking speed data（歩くスピード）
 */
public struct WalkingSpeed: Codable {
    private static let logger = Logger(category: .model)

    public let start: Date
    public let end: Date
    public let speed: Float

    public init (
        start: Date,
        end: Date,
        speed: Float
    ) {
        self.start = start
        self.end = end
        self.speed = speed
    }
}

extension WalkingSpeed {
    public static let noData: WalkingSpeed = .init(start: Date(), end: Date(), speed: 0)

    public static func load(for date: Date) async throws -> WalkingSpeed {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.endOfDay(for: date)
        return try await load(start: startOfDay, end: endOfDay)
    }

    public static func load(start: Date, end: Date) async throws -> WalkingSpeed {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let walkingSpeedQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: walkingSpeedQuantityType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in

                if let error = error {
                    logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics,
                      let average = statistics.averageQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let speed: Float = Float(
                    truncating: (average.doubleValue(for: .meter().unitDivided(by: HKUnit.second()))) as NSNumber
                )

                continuation.resume(returning:
                        .init(
                            start: start,
                            end: end,
                            speed: speed
                        )
                )
            }

            HKHealthStore.shared.execute(query)
        }
    }
}
