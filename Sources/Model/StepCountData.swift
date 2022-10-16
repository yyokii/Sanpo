import Combine
import Foundation
import HealthKit
import os.log

import Extension

/**
 The data provider that continuously loads StepCount data
 */
@MainActor
public class StepCountData: ObservableObject {
    let logger = Logger(category: .model)

    @Published public var todayStepCount: StepCount?

    private var updateStepCountTimer: Timer?

    public init() {
        Task.detached {
            await self.loadTodayStepCount()
        }
        updateStepCountTimer = Timer.scheduledTimer(
            timeInterval: 60.0,
            target: self,
            selector: #selector(fireUpdateStepCountTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func fireUpdateStepCountTimer() {
        Task.detached {
            await self.loadTodayStepCount()
        }
    }

    public func loadTodayStepCount() async {
        let todayData = await StepCount.load(for: Date())
        todayStepCount = todayData
    }
}
