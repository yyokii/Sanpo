import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Active energy burned data（活動エネルギー消費量）
 */
public struct ActiveEnergyBurned: Codable {
    private static let logger = Logger(category: .model)

    public let start: Date
    public let end: Date
    public let energy: Float

    public init (
        start: Date,
        end: Date,
        energy: Float
    ) {
        self.start = start
        self.end = end
        self.energy = energy
    }
}

extension ActiveEnergyBurned {
    public static let noData: ActiveEnergyBurned = .init(start: Date(), end: Date(), energy: 0)

    public static func load(for date: Date) async throws -> ActiveEnergyBurned {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.endOfDay(for: date)

        return try await load(start: startOfDay, end: endOfDay)
    }

    public static func load(start: Date, end: Date) async throws -> ActiveEnergyBurned {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let activeEnergyBurned = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: activeEnergyBurned,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in

                if let error = error {
                    logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                }

                guard let statistics,
                      let sum = statistics.sumQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let energy: Float = Float(
                    truncating: (sum.doubleValue(for: .kilocalorie())) as NSNumber
                )

                continuation.resume(returning:
                        .init(
                            start: start,
                            end: end,
                            energy: energy
                        )
                )
            }

            HKHealthStore.shared.execute(query)
        }
    }
}
