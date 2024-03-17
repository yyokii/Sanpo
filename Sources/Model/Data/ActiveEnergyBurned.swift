import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Data Objects

 Active energy burned data（活動エネルギー消費量） for a specific day
 */
public struct ActiveEnergyBurned: Codable {
    private static let logger = Logger(category: .model)

    public let date: Date
    public let energy: Float

    public init (
        date: Date,
        energy: Float
    ) {
        self.date = date
        self.energy = energy
    }
}

extension ActiveEnergyBurned {
    public static let noData: ActiveEnergyBurned = .init(date: Date(), energy: 0)

    public static func load(for date: Date) async -> ActiveEnergyBurned {
        if HKHealthStore.isHealthDataAvailable() {
            let walkingSpeedQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.endOfDay(for: date)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: endOfDay,
                options: .strictStartDate
            )

            return await withCheckedContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: walkingSpeedQuantityType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in

                    if let error = error {
                        logger.debug("\(error.localizedDescription)")
                        continuation.resume(returning: ActiveEnergyBurned.noData)
                        return
                    }

                    guard let statistics,
                          let sum = statistics.sumQuantity() else {
                        continuation.resume(returning: ActiveEnergyBurned.noData)
                        return
                    }

                    let energy: Float = Float(
                        truncating: (sum.doubleValue(for: .kilocalorie())) as NSNumber
                    )

                    continuation.resume(returning:
                            .init(
                                date: startOfDay,
                                energy: energy
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
