import Foundation
import HealthKit

import Extension

/**
 Data Objects

 Steps data for a specific day
*/
public struct StepCount {
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
}
