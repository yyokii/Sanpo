//
//  iOSDevelopApp.swift
//  iOSDevelop
//
//  Created by Higashihara Yoki on 2022/09/18.
//

import SwiftUI

import Constant
import MainTab
import Model

@main
struct iOSDevelopApp: App {
    @StateObject var myGoalStore = MyGoalStore()

    init() {
        let userDefaults = UserDefaults(suiteName: UserDefaultsSuitName.app.rawValue)!

        userDefaults.register(
            defaults: [UserDefaultsKey.dailyTargetSteps.rawValue: 8000]
        )
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(myGoalStore)
        }
    }
}
