import Foundation

import Constant

/**
 State Objects
*/
public class MyGoalStore: ObservableObject {
    @Published public var dailyTargetSteps: Int = 0

    let userDefaults = UserDefaults(suiteName: UserDefaultsSuitName.app.rawValue)!

    public init() {
   
        dailyTargetSteps = userDefaults.integer(forKey: UserDefaultsKey.dailyTargetSteps.rawValue)
    }

    public func updateDailyTargetSteps(_ steps: Int) {
        userDefaults.set(steps, forKey: UserDefaultsKey.dailyTargetSteps.rawValue)
        dailyTargetSteps = steps
    }
}
