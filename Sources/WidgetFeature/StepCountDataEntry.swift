import WidgetKit

public struct StepCountDataEntry: TimelineEntry {
    public var date: Date

    let todayStepCount: Int
    let dailyGoal: Int

    public init(date: Date, todayStepCount: Int, dailyGoal: Int) {
        self.date = date
        self.todayStepCount = todayStepCount
        self.dailyGoal = dailyGoal
    }
}
