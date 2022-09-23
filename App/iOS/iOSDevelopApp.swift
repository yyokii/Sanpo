//
//  iOSDevelopApp.swift
//  iOSDevelop
//
//  Created by Higashihara Yoki on 2022/09/18.
//

import SwiftUI
import Model
import HomeFeature

@main
struct iOSDevelopApp: App {
    @StateObject var stepCountStore = StepCountStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(stepCountStore)
        }
    }
}
