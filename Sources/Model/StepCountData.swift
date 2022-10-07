import Combine
import Foundation
import HealthKit
import os.log

/**
 The data provider that loads StepCount data
 */
@MainActor
public class StepCountData: ObservableObject {
    let logger = Logger(subsystem: "com.yyokii.sanpo.StepCountData", category: "Model")

    @Published public var todayStepCount: StepCount?

    public enum Phase {
        case waiting
        case success
        case failure(Error?)
    }
    @Published public var phase: Phase = .waiting

    private var updateStepCountTimer: Timer?

    public init() {
        loadTodayStepCount()
        updateStepCountTimer = Timer.scheduledTimer(
            timeInterval: 60.0,
            target: self,
            selector: #selector(fireUpdateStepCountTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func fireUpdateStepCountTimer() {
        loadTodayStepCount()
    }

    private func loadTodayStepCount() {
        Task.detached { @MainActor in
            let todayData = await StepCount.today()
            self.todayStepCount = todayData
            self.phase = .success
        }
    }
}
