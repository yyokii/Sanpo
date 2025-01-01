import Foundation

public struct MockHealthDataClient: HealthDataClientProtocol {
    public init() {}

    public func loadActiveEnergyBurned(for date: Date) async throws -> ActiveEnergyBurned {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)
        return .init(start: start, end: end, energy: .random(in: 100...2000))
    }
    
    public func loadDistanceWalkingRunning(for date: Date) async throws -> DistanceWalkingRunning {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)
        return .init(start: start, end: end, distance: .random(in: 100...20000))
    }
    
    public func loadStepCount(start: Date, end: Date) async throws -> [Date : StepCount] {
        let calendar = Calendar.current
        var data: [Date: StepCount] = [:]

        if let startDate = calendar.date(from: DateComponents(year: 2024, month: 11, day: 1)) {
            for dayOffset in 0..<90 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                    data[date] = .init(start: date, end: date, number: Int.random(in: 1000...15000))
                }
            }
        }

        return data
    }

    public func loadYearlyStepCount(startYear: Int, endYear: Int) async throws -> [Int : StepCount] {
        return [
            2023: .init(start: .now, end: .now, number: .random(in: 100...50000)),
            2024: .init(start: .now, end: .now, number: .random(in: 100...50000)),
            2025: .init(start: .now, end: .now, number: .random(in: 100...50000))
        ]
    }

    public func loadMonthlyStepCount(start: Date, end: Date) async throws -> [Date : StepCount] {
        let calendar = Calendar.current
        let now = Date()
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        var mockData: [Date: StepCount] = [:]

        for i in 0..<3 {
            if let monthStartDate = calendar.date(byAdding: .month, value: -i, to: startOfCurrentMonth) {
                let monthEndDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStartDate)!
                mockData[monthStartDate] = StepCount(
                    start: monthStartDate,
                    end: monthEndDate,
                    number: .random(in: 100...50000)
                )
            }
        }

        return mockData
    }

    public func loadStepCount(for date: Date) async throws -> StepCount {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)
        return .init(start: start, end: end, number: .random(in: 100...50000))
    }
    
    public func fetchDisplayedDataInWidget() -> StepCount {
        let now: Date = .now
        let start = Calendar.current.startOfDay(for: now)
        let end = Calendar.current.endOfDay(for: now)
        return .init(start: start, end: end, number: .random(in: 100...50000))
    }
    
    public func loadWalkingSpeed(for date: Date) async throws -> WalkingSpeed {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)
        return .init(start: start, end: end, speed: .random(in: 1...10))
    }
    
    public func loadWalkingStepLength(for date: Date) async throws -> WalkingStepLength {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.endOfDay(for: date)
        return .init(start: start, end: end, length: .random(in: 0.1...2))
    }
}
