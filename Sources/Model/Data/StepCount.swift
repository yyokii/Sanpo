import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Data Objects

 Steps data for a specific day
 */
public struct StepCount: Codable {
    private static let logger = Logger(category: .model)

    public let date: Date
    public let number: Int

    public init (
        date: Date,
        number: Int
    ) {
        self.date = date
        self.number = number
    }

    public func saveAsDisplayedInWidget() {
        // swiftlint:disable force_try
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: UserDefaultsKey.displayedStepCountDataInWidget.rawValue)
    }
}

extension StepCount {
    public static let noData: StepCount = .init(date: Date(), number: 0)

    public static func range(start: Date, end: Date) async -> [Date: StepCount] {
        if HKHealthStore.isHealthDataAvailable() {
            let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let now = Date()
            let todayStart: Date = Calendar.current.startOfDay(for: now)

            // HKSampleQuery を使用してその合計値を歩数のデータにすると、HealthStoreにはiPhoneとApple Watchが自動記録した歩数データが入っているため
            // それら二つの歩数計データを足し合わせてしますことになる
            // 従って、HKStatisticsCollectionQuery を使用する
            // https://qiita.com/sato-shin/items/a1b6026359d340afe91b#o-hkstatisticsquery--hkstatisticscollectionquery-%E3%81%A7%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: todayStart,
                intervalComponents: DateComponents(day: 1)
            )

            return await withCheckedContinuation { continuation in
                query.initialResultsHandler = { _, collection, error in
                    if let error = error {
                        logger.debug("\(error.localizedDescription)")
                        continuation.resume(returning: [:])
                        return
                    }

                    guard let statistics = collection?.statistics() else {
                        continuation.resume(returning: [:])
                        return
                    }

                    var dic: [Date: StepCount] = [:]
                    statistics.forEach({ data in
                        let number: Int = Int(
                            truncating: (data.sumQuantity()?.doubleValue(for: .count()) ?? 0) as NSNumber
                        )
                        let stepCount = StepCount(
                            date: data.startDate,
                            number: number
                        )
                        dic[data.startDate] = stepCount
                    })

                    continuation.resume(returning: dic)
                }
                HKHealthStore.shared.execute(query)
            }
        } else {
            return [:]
        }
    }

    public static func load(for date: Date) async -> StepCount {
        if HKHealthStore.isHealthDataAvailable() {
            let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.endOfDay(for: date)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: endOfDay,
                options: .strictStartDate
            )

            return await withCheckedContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepsQuantityType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in

                    if let error = error {
                        logger.debug("\(error.localizedDescription)")
                        continuation.resume(returning: StepCount.noData)
                        return
                    }

                    guard let statistics = statistics, let sum = statistics.sumQuantity() else {
                        continuation.resume(returning: StepCount.noData)
                        return
                    }

                    let number: Int = Int(
                        truncating: (sum.doubleValue(for: .count())) as NSNumber
                    )

                    continuation.resume(returning:
                            .init(
                                date: startOfDay,
                                number: number
                            )
                    )
                }

                HKHealthStore.shared.execute(query)
            }
        } else {
            return .noData
        }
    }

    public static func displayedDataInWidget() -> StepCount {
        var result: StepCount

        if let savedData = UserDefaults.standard.data(forKey: UserDefaultsKey.displayedStepCountDataInWidget.rawValue) {
            result = try! JSONDecoder().decode(StepCount.self, from: savedData)
        } else {
            let saveData = StepCount.noData
            saveData.saveAsDisplayedInWidget()
            result = saveData
        }

        return result
    }
}
