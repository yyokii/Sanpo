import Foundation

@Observable
public class MyDataModel {

    public var stepCounts: [Date: StepCount] = [:]

    private let healthDataClient: HealthDataClientProtocol

    public init(healthDataClient: HealthDataClientProtocol) {
        self.healthDataClient = healthDataClient
    }

    public func loadStepCounts() async {
        let calendar = Calendar.current
        // HealthKit is available from iOS 8(2014/9/17)
        let startDate = DateComponents(year: 2014, month: 9, day: 1, hour: 0, minute: 0, second: 0)
        if let stepCounts = try? await healthDataClient.loadStepCount(
            start: calendar.date(from: startDate)!,
            end: Date()
        ) {
            self.stepCounts = stepCounts
        }
    }
}
