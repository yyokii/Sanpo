import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Walking speed data（歩くスピード） for a specific day
 */
public struct WalkingSpeed: Codable {
    private static let logger = Logger(category: .model)

    public let date: Date
    public let speed: Float

    public init (
        date: Date,
        speed: Float
    ) {
        self.date = date
        self.speed = speed
    }
}

extension WalkingSpeed {
    public static let noData: WalkingSpeed = .init(date: Date(), speed: 0)

    public static func load(for date: Date) async -> WalkingSpeed {
        if HKHealthStore.isHealthDataAvailable() {
            let walkingSpeedQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!

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
                    options: .discreteAverage
                ) { _, statistics, error in

                    if let error = error {
                        logger.debug("\(error.localizedDescription)")
                        continuation.resume(returning: WalkingSpeed.noData)
                        return
                    }

                    guard let statistics,
                          let average = statistics.averageQuantity() else {
                        continuation.resume(returning: WalkingSpeed.noData)
                        return
                    }

                    let speed: Float = Float(
                        truncating: (average.doubleValue(for: .meter().unitDivided(by: HKUnit.second()))) as NSNumber
                    )

                    continuation.resume(returning:
                            .init(
                                date: startOfDay,
                                speed: speed
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
