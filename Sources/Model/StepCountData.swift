import CoreMotion
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

    private let pedometer = CMPedometer()

    public init() {
        observeTodayStepCount()
    }

    func observeTodayStepCount() {
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
