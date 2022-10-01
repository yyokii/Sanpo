import SwiftUI
import WidgetKit

import Constant
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
            todayStepCount: 1000,
            dailyGoal: 8000
        )
        completion(entry)
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<StepCountDataEntry>) -> Void) {
        Task.detached {
            let now = Date()
            let todayStepCount: StepCount = await StepCount.today()

            let entry = StepCountDataEntry(
                date: now,
                todayStepCount: todayStepCount.number,
                dailyGoal: UserDefaults.app.integer(forKey: UserDefaultsKey.dailyTargetSteps.rawValue)
            )

            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}
