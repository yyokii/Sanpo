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
            /*
             > The user’s device stores all HealthKit data locally.
             > For security, the device encrypts the HealthKit store when the user locks the device.
             > As a result, your app may not be able to read data from the store when it runs in the background.
             > However, your app can still write to the store, even when the phone is locked.
             > HealthKit temporarily caches the data and saves it to the encrypted store
             > as soon as the user unlocks the phone.

             https://developer.apple.com/documentation/healthkit/protecting_user_privacy

             端末がロック状態だとHealthKitからデータ取得ができないので、表示データをローカルに保存しておき、
             その値より値が増えている場合のみ最新データを表示する。
             */

            let now = Date()
            let dailyTargetSteps: Int = UserDefaults.app.integer(forKey: UserDefaultsKey.dailyTargetSteps.rawValue)
            guard let todayStepCount: StepCount = try? await StepCount.load(for: now) else {
                return
            }
            let displayedDataInWidget: StepCount = StepCount.fetchDisplayedDataInWidget()

            var entry: StepCountDataEntry
            if Calendar.current.isDate(now, inSameDayAs: displayedDataInWidget.start) {
                let isNewDataIncreasing: Bool = todayStepCount.number > displayedDataInWidget.number
                let data: StepCount = isNewDataIncreasing ? todayStepCount : displayedDataInWidget
                data.saveAsDisplayedInWidget()
                entry = StepCountDataEntry(
                    date: now,
                    todayStepCount: data.number,
                    dailyGoal: dailyTargetSteps
                )
            } else {
                todayStepCount.saveAsDisplayedInWidget()
                entry = StepCountDataEntry(
                    date: now,
                    todayStepCount: todayStepCount.number,
                    dailyGoal: dailyTargetSteps
                )
            }

            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: now)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}
