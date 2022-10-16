import Combine
import HealthKit
import os.log

import Extension

public class HealthKitAuthService: NSObject, ObservableObject {
    private let logger = Logger(category: .service)

    static public let shared = HealthKitAuthService()

    @Published public var authStatus: HKAuthorizationRequestStatus?

    let readTypes = Set(
        [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!
        ]
    )

    override private init() {
        super.init()
    }

    public func loadAuthorization() {
        HKHealthStore.shared.getRequestStatusForAuthorization(toShare: [], read: readTypes) { status, error in

            if let error {
                self.logger.debug("\(error.localizedDescription)")
            }

            self.authStatus = status
        }
    }

    public func requestAuthorization() async {
        try? await HKHealthStore.shared.requestAuthorization(toShare: [], read: self.readTypes)
    }
}
