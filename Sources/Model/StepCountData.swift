import Combine
import Foundation
import HealthKit
import os.log
import WidgetKit

import Extension

/**
 The data provider that continuously loads StepCount data
 */
@MainActor
public class StepCountData: ObservableObject {
    let logger = Logger(category: .model)

    @Published public var todayStepCount: StepCount?
    @Published public var yesterdayStepCount: StepCount?

    private var updateStepCountTimer: Timer?

    public init() {
        Task {
            await self.loadTodayStepCount()
            await self.loadYesterdayStepCount()
        }
        updateStepCountTimer = Timer.scheduledTimer(
            timeInterval: 10.0,
            target: self,
            selector: #selector(fireUpdateStepCountTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func fireUpdateStepCountTimer() {
        Task {
            await self.loadTodayStepCount()
        }
    }

    public func loadTodayStepCount() async {
        let todayData = try? await StepCount.load(for: Date())
        todayStepCount = todayData
        WidgetCenter.shared.reloadAllTimelines()
    }

    public func loadYesterdayStepCount() async {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return
        }
        let yesterdayData = try? await StepCount.load(for: yesterday)
        yesterdayStepCount = yesterdayData
    }
}
