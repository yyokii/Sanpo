import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Data Objects

 Walking speed length data（歩幅） for a specific day
 */
public struct WalkingStepLength: Codable {
    private static let logger = Logger(category: .model)

    public let date: Date
    public let length: Float

    public init (
        date: Date,
        length: Float
    ) {
        self.date = date
        self.length = length
    }
}

extension WalkingStepLength {
    public static let noData: WalkingStepLength = .init(date: Date(), length: 0)

    public static func load(for date: Date) async -> WalkingStepLength {
        if HKHealthStore.isHealthDataAvailable() {
            let walkingStepLengthQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!

            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.endOfDay(for: date)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: endOfDay,
                options: .strictStartDate
            )

            return await withCheckedContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: walkingStepLengthQuantityType,
                    quantitySamplePredicate: predicate,
                    options: .discreteAverage
                ) { _, statistics, error in

                    if let error = error {
                        logger.debug("\(error.localizedDescription)")
                        continuation.resume(returning: WalkingStepLength.noData)
                        return
                    }

                    guard let statistics = statistics, let sum = statistics.averageQuantity() else {
                        continuation.resume(returning: WalkingStepLength.noData)
                        return
                    }

                    let length: Float = Float(
                        truncating: (sum.doubleValue(for: .meter())) as NSNumber
                    )
                    continuation.resume(returning:
                            .init(
                                date: startOfDay,
                                length: length
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
