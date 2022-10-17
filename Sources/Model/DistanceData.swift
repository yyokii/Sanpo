import Combine
import Foundation
import HealthKit
import os.log

/**
 The data provider that continuously loads StepCount data
 */
@MainActor
public class DistanceData: ObservableObject {
    let logger = Logger(category: .model)

    @Published public var todayDistance: DistanceWalkingRunning?

    private var updateDistanceTimer: Timer?

    public init() {
        Task.detached {
            await self.loadTodayDistance()
        }

        updateDistanceTimer = Timer.scheduledTimer(
            timeInterval: 60.0,
            target: self,
            selector: #selector(fireUpdateDistanceTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func fireUpdateDistanceTimer() {
        Task.detached {
            await self.loadTodayDistance()
        }
    }

    private func loadTodayDistance() async {
        let todayData = await DistanceWalkingRunning.today()
        self.todayDistance = todayData
    }
}
