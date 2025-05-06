import Combine
import HealthKit
import CoreLocation
import Service

@MainActor
public class WorkoutData: NSObject, ObservableObject {
    @Published public var isWalking: Bool = false
    @Published public var errorMessage: String?

    private var workoutStartDate: Date?

    private let locationService = LocationService.shared
    private let healthLitService = HealthKitAuthService.shared

    private let locationManager = CLLocationManager()
    // https://developer.apple.com/documentation/healthkit/hkdevice/1615276-local
    private let routeBuilder = HKWorkoutRouteBuilder(healthStore: .shared, device: .local())
    private let workoutBuilder: HKWorkoutBuilder

    public override init() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking

        workoutBuilder = HKWorkoutBuilder(
            healthStore: .shared,
            configuration: workoutConfiguration,
            device: .local()
        )
    }

    // https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/creating_a_workout_route
    public func startWorkout() async throws {
        errorMessage = nil

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        let workoutStartDate: Date = .now
        try await workoutBuilder.beginCollection(at: workoutStartDate)

        self.workoutStartDate = workoutStartDate
        isWalking = true
    }

    public func finishWorkout() async throws {
        guard let workoutStartDate else {
            return
        }
        // finishRouteで使用するHKWorkoutのinitはdeprecatedであり、HKWorkoutBuilderの使用が推奨されているのでそちらを使用。
        do {
            let endDate: Date = .now
            // 関連データの取得
            async let stepCount = fetchDataOrNil { try await StepCount.load(start: workoutStartDate, end: endDate) }
            async let activeEnergyBurned = fetchDataOrNil { try await ActiveEnergyBurned.load(start: workoutStartDate, end: endDate) }
            async let distance = fetchDataOrNil { try await DistanceWalkingRunning.load(start: workoutStartDate, end: endDate) }
            async let walkingSpeed = fetchDataOrNil { try await WalkingSpeed.load(start: workoutStartDate, end: endDate) }
            async let stepLength = fetchDataOrNil { try await WalkingStepLength.load(start: workoutStartDate, end: endDate) }

            let datas = await (stepCount: stepCount, activeEnergyBurned: activeEnergyBurned, distance: distance, walkingSpeed: walkingSpeed, stepLength: stepLength)
            var samples: [HKSample] = []

            if let stepCount = datas.stepCount {
                samples.append(stepCount.sampleData)
            }

            if let activeEnergyBurned = datas.activeEnergyBurned {
                samples.append(activeEnergyBurned.sampleData)
            }

            if let distance = datas.distance {
                samples.append(distance.sampleData)
            }
            if let walkingSpeed = datas.walkingSpeed {
                samples.append(walkingSpeed.sampleData)
            }

            if let stepLength = datas.stepLength {
                samples.append(stepLength.sampleData)
            }

            if !samples.isEmpty {
                try await workoutBuilder.addSamples(samples)
            }

            try await workoutBuilder.endCollection(at: endDate)

            guard let workout = try await workoutBuilder.finishWorkout() else {
                return
            }
            try await routeBuilder.finishRoute(with: workout, metadata: .none)
            // TODO: routeを使って描画とかする
            await self.updateWalkingStatus(false, errorMessage: nil)
            self.workoutStartDate = nil
        } catch {
            // TODO: throw する
            await self.updateWalkingStatus(false, errorMessage:  error.localizedDescription)
        }
    }

    @MainActor
    private func updateWalkingStatus(_ isWalking: Bool, errorMessage: String?) async {
        self.isWalking = isWalking
        self.errorMessage = errorMessage
    }
    
    private func fetchDataOrNil<T>(loadFunction: @escaping () async throws -> T) async -> T? {
        do {
            return try await loadFunction()
        } catch {
            return nil
        }
    }
}

extension WorkoutData: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
        }

        guard !filteredLocations.isEmpty else {

            return
        }

        // Add the filtered data to the route.
        routeBuilder.insertRouteData(filteredLocations) { (success, error) in
            if !success {
                // TODO: Handle any errors here.
                print(error?.localizedDescription ?? "")
            }
        }
    }
}
