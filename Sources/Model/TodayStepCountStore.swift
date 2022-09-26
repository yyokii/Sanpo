import Foundation
import CoreMotion

import Constant

/**
 State Objects
 */
@MainActor
public class TodayStepCountStore: ObservableObject {
    @Published public var todayStepCount: StepCount?
    @Published public var dailyTargetSteps: Int = 8_000

    public enum Phase {
        case waiting
        case success
        case failure(Error?)
    }
    @Published public var phase: Phase = .waiting

    let pedometer = CMPedometer()

    public init() {
        loadTodayStepCount()
    }

    func loadTodayStepCount() {
        phase = .waiting
        let now = Date()
        let todayStart: Date = Calendar.current.startOfDay(for: now)

        pedometer.startUpdates(from: todayStart) { [weak self] pedometerData, error in
            guard let self = self else {
                return
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.phase = .failure(error)
                }
                return
            }

            if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self.phase = .success
                    self.todayStepCount = .init(
                        date: now,
                        number: Int(truncating: pedometerData.numberOfSteps),
                        distance: Int(truncating: pedometerData.distance ?? 0)
                    )
                }
            } else {
                DispatchQueue.main.async {
                    self.phase = .failure(nil)
                }
            }
        }
    }
}
