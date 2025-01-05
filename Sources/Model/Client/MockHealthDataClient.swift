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

    public func loadWeeklyAverageStepCount(start: Date, end: Date) async throws -> [Date: StepCount] {
        let calendar = Calendar.current

        // Calculate the start of the first week and the end of the last week based on the provided range
        let startOfFirstWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: start))!
        let endOfLastWeek = calendar.date(byAdding: DateComponents(day: 6), to: calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: end))!)!

        var mockData: [Date: StepCount] = [:]

        // Generate mock data for each week in the range
        var currentStart = startOfFirstWeek
        while currentStart <= endOfLastWeek {
            let currentEnd = calendar.date(byAdding: DateComponents(day: 6), to: currentStart)!
            mockData[currentStart] = StepCount(
                start: currentStart,
                end: currentEnd,
                number: .random(in: 1000...70000) // Random steps for the week
            )
            currentStart = calendar.date(byAdding: .day, value: 7, to: currentStart)!
        }
        return mockData
    }

    public func loadMonthlyAverageStepCount(start: Date, end: Date) async throws -> [Date: StepCount] {
        let calendar = Calendar.current
        let startOfFirstMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: start))!
        let endOfLastMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: end))!

        var mockData: [Date: StepCount] = [:]

        var currentMonth = startOfFirstMonth
        while currentMonth <= endOfLastMonth {
            let monthEndDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: currentMonth)!
            mockData[currentMonth] = StepCount(
                start: currentMonth,
                end: monthEndDate,
                number: .random(in: 1000...70000) // Random steps for the month
            )
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
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
