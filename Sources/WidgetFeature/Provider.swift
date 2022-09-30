import SwiftUI
import WidgetKit

import Model

public struct Provider: TimelineProvider {

    public init() {}

    public func placeholder(in context: Context) -> StepCountDataEntry {
        StepCountDataEntry(
            date: Date(),
            todayStepCount: 0,
            dailyGoal: 8000
        )
    }

    public func getSnapshot(in context: Context, completion: @escaping (StepCountDataEntry) -> Void) {
        let entry = StepCountDataEntry(
            date: Date(),
            todayStepCount: 0,
            dailyGoal: 8000
        )
        completion(entry)
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<StepCountDataEntry>) -> Void) {
        var entries: [StepCountDataEntry] = []

        let currentDate = Date()

        let todayStepCount: StepCount = StepCount.todayDataOfCurrentDevice()

        let entry = StepCountDataEntry(
            date: currentDate,
            todayStepCount: todayStepCount.number,
            dailyGoal: 8000
        )
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}
