import Foundation

import Constant

/**
 State Objects
*/
public class MyGoalStore: ObservableObject {
    @Published public var dailyTargetSteps: Int = 0

    let userDefaults = UserDefaults(suiteName: UserDefaultsSuitName.app.rawValue)

    public init() {
        if let userDefaults = userDefaults {
            userDefaults.register(
                defaults: [UserDefaultsKey.dailyTargetSteps.rawValue: 8000]
            )
        }
        load()
    }

    func load() {
        if let dailyTargetSteps = userDefaults?.integer(forKey: UserDefaultsKey.dailyTargetSteps.rawValue) {
            self.dailyTargetSteps = dailyTargetSteps
        } else {
            dailyTargetSteps = 8000
        }
    }

    public func updateDailyTargetSteps(_ steps: Int) {
        userDefaults?.set(steps, forKey: UserDefaultsKey.dailyTargetSteps.rawValue)
        dailyTargetSteps = steps
    }
}
