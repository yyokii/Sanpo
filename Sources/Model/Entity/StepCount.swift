import Foundation
import HealthKit
import os.log

import Constant
import Extension

/**
 Steps data for a specific day
 */
public struct StepCount: Codable {
    private static let logger = Logger(category: .model)

    public let start: Date
    public let end: Date
    public let number: Int

    public init (
        start: Date,
        end: Date,
        number: Int
    ) {
        self.start = start
        self.end = end
        self.number = number
    }

    public func saveAsDisplayedInWidget() {
        // swiftlint:disable force_try
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: UserDefaultsKey.displayedStepCountDataInWidget.rawValue)
    }
}

extension StepCount {
    public static let noData: StepCount = .init(start: Date(), end: Date(), number: 0)

    /// 特定期間について、歩数データを日別で取得する
    public static func range(start: Date, end: Date) async throws -> [Date: StepCount] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let now = Date()
        let todayStart: Date = Calendar.current.startOfDay(for: now)

        // HKSampleQuery を使用してその合計値を歩数のデータにすると、HealthStoreにはiPhoneとApple Watchが自動記録した歩数データが入っているため
        // それら二つの歩数計データを足し合わせてしますことになる
        // 従って、HKStatisticsQuery / HKStatisticsCollectionQuery を使用する
        // https://qiita.com/sato-shin/items/a1b6026359d340afe91b#o-hkstatisticsquery--hkstatisticscollectionquery-%E3%81%A7%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B
        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: todayStart,
            intervalComponents: DateComponents(day: 1)
        )

        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { _, collection, error in
                if let error = error {
                    logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = collection?.statistics() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                var dic: [Date: StepCount] = [:]
                statistics.forEach({ data in
                    let number: Int = Int(
                        truncating: (data.sumQuantity()?.doubleValue(for: .count()) ?? 0) as NSNumber
                    )
                    let stepCount = StepCount(
                        start: start,
                        end: end,
                        number: number
                    )
                    dic[data.startDate] = stepCount
                })

                continuation.resume(returning: dic)
            }
            HKHealthStore.shared.execute(query)
        }
    }

    public static func load(for date: Date) async throws -> StepCount {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.endOfDay(for: date)
        return try await load(start: startOfDay, end: endOfDay)
    }

    public static func load(start: Date, end: Date) async throws -> StepCount {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsQuantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in

                if let error = error {
                    logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = statistics, let sum = statistics.sumQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let number: Int = Int(
                    truncating: (sum.doubleValue(for: .count())) as NSNumber
                )

                continuation.resume(returning:
                        .init(
                            start: start,
                            end: end,
                            number: number
                        )
                )
            }

            HKHealthStore.shared.execute(query)
        }
    }

    public static func fetchDisplayedDataInWidget() -> StepCount {
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
