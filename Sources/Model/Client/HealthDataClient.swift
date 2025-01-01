import Constant
import Foundation
import HealthKit
import os.log

public protocol HealthDataClientProtocol {
    func loadActiveEnergyBurned(for date: Date) async throws -> ActiveEnergyBurned

    func loadDistanceWalkingRunning(for date: Date) async throws -> DistanceWalkingRunning

    func loadStepCount(for date: Date) async throws -> StepCount
    func loadStepCount(start: Date, end: Date) async throws -> [Date: StepCount]
    func loadMonthlyStepCount(start: Date, end: Date) async throws -> [Date: StepCount]
    func loadYearlyStepCount(startYear: Int, endYear: Int) async throws -> [Int : StepCount]
    func fetchDisplayedDataInWidget() -> StepCount

    /// 特定日の平均歩行時速（時速）
    func loadWalkingSpeed(for date: Date) async throws -> WalkingSpeed

    /// 特定日の平均歩幅（m）
    func loadWalkingStepLength(for date: Date) async throws -> WalkingStepLength
}

public class HealthDataClient: HealthDataClientProtocol {
    public static let shared = HealthDataClient()

    private let logger = Logger(category: .model)

    private init() {}

    public func loadActiveEnergyBurned(for date: Date) async throws -> ActiveEnergyBurned {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)

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
                    self.logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
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

    public func loadDistanceWalkingRunning(for date: Date) async throws -> DistanceWalkingRunning {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)

        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
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
                    self.logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = statistics, let sum = statistics.sumQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let distance: Int = Int(
                    truncating: (sum.doubleValue(for: .meter())) as NSNumber
                )

                continuation.resume(returning:
                        .init(
                            start: start,
                            end: end,
                            distance: distance
                        )
                )
            }
            HKHealthStore.shared.execute(query)
        }
    }

    public func loadStepCount(for date: Date) async throws -> StepCount {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)

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
                    self.logger.debug("\(error.localizedDescription)")
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

    /// 引数で指定された期間で、毎日の歩数を取得する
    ///
    /// StepCount自体もdate情報を持つが、日付の指定によってはデータがおおくなるのでo(1)でアクセスできるように戻り値を辞書型にしている
    public func loadStepCount(start: Date, end: Date) async throws -> [Date : StepCount] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        // anchorの作成。日付は関係なく、何時を境にして集計するかを決める。
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
                    self.logger.debug("\(error.localizedDescription)")
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
                        start: data.startDate,
                        end: data.endDate,
                        number: number
                    )
                    dic[data.startDate] = stepCount
                })

                continuation.resume(returning: dic)
            }
            HKHealthStore.shared.execute(query)
        }
    }

    public func loadMonthlyStepCount(start: Date, end: Date) async throws -> [Date: StepCount] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }

        let calendar = Calendar.current
        let startOfFirstMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: start))!
        let endOfLastMonth = calendar.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: calendar.date(from: calendar.dateComponents([.year, .month], from: end))!
        )!

        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfFirstMonth, end: endOfLastMonth)

        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: startOfFirstMonth),
            intervalComponents: DateComponents(month: 1)
        )

        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { _, collection, error in
                if let error = error {
                    self.logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = collection?.statistics() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                var monthlySteps: [Date: StepCount] = [:]
                statistics.forEach { data in
                    let totalSteps = Int(
                        truncating: (data.sumQuantity()?.doubleValue(for: .count()) ?? 0) as NSNumber
                    )
                    let stepCount = StepCount(
                        start: data.startDate,
                        end: data.endDate,
                        number: totalSteps
                    )
                    monthlySteps[data.startDate] = stepCount
                }

                continuation.resume(returning: monthlySteps)
            }
            HKHealthStore.shared.execute(query)
        }
    }

    public func loadYearlyStepCount(startYear: Int, endYear: Int) async throws -> [Int : StepCount] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }

        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: startYear, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: endYear, month: 12, day: 31, hour: 23, minute: 59, second: 59))!

        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: start),
            intervalComponents: DateComponents(year: 1)
        )

        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { _, collection, error in
                if let error = error {
                    self.logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = collection?.statistics() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                var yearlySteps: [Int: StepCount] = [:]
                statistics.forEach({ data in
                    let year = calendar.component(.year, from: data.startDate)
                    let number: Int = Int(
                        truncating: (data.sumQuantity()?.doubleValue(for: .count()) ?? 0) as NSNumber
                    )
                    let stepCount = StepCount(
                        start: data.startDate,
                        end: data.endDate,
                        number: number
                    )
                    yearlySteps[year] = stepCount
                })

                continuation.resume(returning: yearlySteps)
            }
            HKHealthStore.shared.execute(query)
        }
    }

    public func fetchDisplayedDataInWidget() -> StepCount {
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

    public func loadWalkingSpeed(for date: Date) async throws -> WalkingSpeed {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)

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
                    self.logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics,
                      let average = statistics.averageQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let speed: Float = Float(
                    truncating: (average.doubleValue(for: .meter().unitDivided(by: HKUnit.hour()))) as NSNumber
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

    public func loadWalkingStepLength(for date: Date) async throws -> WalkingStepLength {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)

        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthDataError.notAvailable
        }
        let walkingStepLengthQuantityType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: walkingStepLengthQuantityType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in

                if let error = error {
                    self.logger.debug("\(error.localizedDescription)")
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                guard let statistics = statistics, let sum = statistics.averageQuantity() else {
                    continuation.resume(throwing: HealthDataError.loadFailed(error))
                    return
                }

                let length: Float = Float(
                    truncating: (sum.doubleValue(for: .meter())) as NSNumber
                )
                continuation.resume(returning:
                        .init(
                            start: start,
                            end: end,
                            length: length
                        )
                )
            }
            HKHealthStore.shared.execute(query)
        }
    }
}
