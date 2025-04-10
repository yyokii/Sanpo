import Combine
import HealthKit
import os.log

import Extension

@MainActor
public class HealthKitAuthService: NSObject, ObservableObject {
    static public let shared = HealthKitAuthService()

    @Published public var isAuthRequestSuccess: Bool = false
    @Published public var authStatus: HKAuthorizationRequestStatus?

    private let logger = Logger(category: .service)

    // The quantity type to write to the health store.
    let typesToShare: Set = [
        HKQuantityType.workoutType(),
        HKSeriesType.workoutRoute()
    ]

    let readTypes = Set(
        [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!,
            HKQuantityType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
    )

    override private init() {
        super.init()

        // preview だとクラッシュするので設定
        if !isPreview {
            loadAuthorization()
        }
    }

    public func loadAuthorization() {
        HKHealthStore.shared.getRequestStatusForAuthorization(toShare: typesToShare, read: readTypes) { status, error in
            if let error {
                self.logger.debug("\(error.localizedDescription)")
            }

            Task.detached { @MainActor in
                self.authStatus = status
            }
        }
    }

    public func requestAuthorization() {
        HKHealthStore.shared.requestAuthorization(toShare: typesToShare, read: readTypes) { success, error in
            if let error {
                self.logger.debug("\(error.localizedDescription)")
            }

            Task.detached { @MainActor in
                self.isAuthRequestSuccess = success
            }
        }
    }
}
