import Combine
import CoreMotion

enum StepCountServiceError: Error {
    case other
}

public protocol StepCountService {}

public final class StepCountServiceImpl: StepCountService, ObservableObject {

    @Published var stepCount: Int?

    let pedometer = CMPedometer()

    public init() {
        pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            guard let self = self,
                  let pedometerData = pedometerData,
                  error == nil else {
                return
            }
            self.stepCount = Int(truncating: pedometerData.numberOfSteps)
        }
    }
}
