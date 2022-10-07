import Combine
import Foundation
import HealthKit
import os.log

/**
 The data provider that loads StepCount data
 */
@MainActor
public class DistanceData: ObservableObject {
    let logger = Logger(subsystem: "com.yyokii.sanpo.DistanceData", category: "Model")

    @Published public var todayDistance: DistanceWalkingRunning?

    public enum Phase {
        case waiting
        case success
        case failure(Error?)
    }
    @Published public var phase: Phase = .waiting

    private var updateDistanceTimer: Timer?

    public init() {
        loadTodayDistance()

        updateDistanceTimer = Timer.scheduledTimer(
            timeInterval: 60.0,
            target: self,
            selector: #selector(fireUpdateDistanceTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func fireUpdateDistanceTimer() {
        loadTodayDistance()
    }

    private func loadTodayDistance() {
        Task.detached { @MainActor in
            let todayData = await DistanceWalkingRunning.today()
            self.todayDistance = todayData
            self.phase = .success
        }
    }
}
