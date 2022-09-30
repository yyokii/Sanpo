import CoreMotion
import Foundation
import HealthKit
import os.log

import Extension

/**
 Data Objects

 Steps data for a specific day
 */
public struct StepCount {
    private static let logger = Logger(subsystem: "com.yyokii.sanpo.StepCount", category: "Model")

    public let date: Date
    public let number: Int
    public let distance: Int?

    public init (
        date: Date,
        number: Int,
        distance: Int?
    ) {
        self.date = date
        self.number = number
        self.distance = distance
    }

    public static func todayCountOfCurrentDevice() -> StepCount {
        let now = Date()
        let todayStart: Date = Calendar.current.startOfDay(for: now)
        let pedometer = CMPedometer()

        var result: StepCount = .init(date: now, number: 0, distance: nil)
        pedometer.queryPedometerData(from: todayStart, to: now) { pedometerData, error in
            if let error = error {
                logger.debug("\(error.localizedDescription)")
                return
            }

            if let pedometerData = pedometerData {
                result = StepCount(
                    date: now,
                    number: Int(truncating: pedometerData.numberOfSteps),
                    distance: Int(truncating: pedometerData.distance ?? 0)
                )
            }
        }
        return result
    }
}
