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

    /*
     userdefaultに表示データを保存して、それより増えてたら更新する、増えてなければ保存地を設定する、日付変わったタイミングで0にリセットする必要あり
     */

    public func getTimeline(in context: Context, completion: @escaping (Timeline<StepCountDataEntry>) -> Void) {

        Task.detached {
            let now = Date()

            print("📝 call StepCount.today()")

            /*
             > The user’s device stores all HealthKit data locally.
             > For security, the device encrypts the HealthKit store when the user locks the device.
             > As a result, your app may not be able to read data from the store when it runs in the background.
             > However, your app can still write to the store, even when the phone is locked.
             > HealthKit temporarily caches the data and saves it to the encrypted store
             > as soon as the user unlocks the phone.

             https://developer.apple.com/documentation/healthkit/protecting_user_privacy
             */
            let todayStepCount: StepCount = await StepCount.today()
            print("📝 value: \(todayStepCount)")

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
