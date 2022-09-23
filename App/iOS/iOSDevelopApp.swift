//
//  iOSDevelopApp.swift
//  iOSDevelop
//
//  Created by Higashihara Yoki on 2022/09/18.
//

import SwiftUI

import MainTab
import Model

@main
struct iOSDevelopApp: App {
    @StateObject var myGoalStore = MyGoalStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(myGoalStore)
        }
    }
}
