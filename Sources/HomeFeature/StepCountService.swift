import Combine
import CoreMotion

enum StepCountServiceError: Error {
    case other
}

public protocol StepCountService {
    var stepCount: Int? { get }
    var stepCountPublisher: Published<Int?>.Publisher { get }
}

public final class StepCountServiceImpl: StepCountService, ObservableObject {

    @Published public var stepCount: Int?
    public var stepCountPublisher: Published<Int?>.Publisher { $stepCount }

    let pedometer = CMPedometer()

    public init() {

        let now = Date()
        let todayStart: Date = Calendar.current.startOfDay(for: now)
        pedometer.startUpdates(from: todayStart) { [weak self] pedometerData, error in
            guard let self = self,
                  let pedometerData = pedometerData,
                  error == nil else {
                return
            }
            self.stepCount = Int(truncating: pedometerData.numberOfSteps)
        }
    }
}
