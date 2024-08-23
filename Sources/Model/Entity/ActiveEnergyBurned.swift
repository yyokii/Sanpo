import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Active energy burned data（活動エネルギー消費量） for a specific day
 */
public struct ActiveEnergyBurned: Codable {
    private static let logger = Logger(category: .model)

    public let startDate: Date
    public let endDate: Date
    public let energy: Float

    public init (
        startDate: Date,
        endDate: Date,
        energy: Float
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.energy = energy
    }
}

extension ActiveEnergyBurned {
    public static let noData: ActiveEnergyBurned = .init(startDate: Date(), endDate: Date(), energy: 0)
    static let activeEnergyBurned = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

    public static func load(for date: Date) async throws -> ActiveEnergyBurned {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.endOfDay(for: date)

        return try await load(start: startOfDay, end: endOfDay)
    }

    public static func load(start: Date, end: Date) async throws -> ActiveEnergyBurned {
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
                            startDate: start,
                            endDate: end,
                            energy: energy
                        )
                )
            }

            HKHealthStore.shared.execute(query)
        }
    }
}
