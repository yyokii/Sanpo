import Combine
import HealthKit
import CoreLocation

public class WorkoutService: NSObject, ObservableObject {
    static public let shared = WorkoutService()

    private let locationService = LocationService.shared
    private let healthLitService = HealthKitAuthService.shared

    private let locationManager = CLLocationManager()
    // https://developer.apple.com/documentation/healthkit/hkdevice/1615276-local
    private let routeBuilder = HKWorkoutRouteBuilder(healthStore: .shared, device: .local())
    private var workoutStartDate: Date?

    override private init() {
        super.init()
    }

    // https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/creating_a_workout_route
    func startWorkout() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        workoutStartDate = .now
    }

    func finishWorkout() {
        // Create, save, and associate the route with the provided workout.
        routeBuilder.finishRoute(with: .init(activityType: .walking, start: workoutStartDate!, end: .now), metadata: .none) { (newRoute, error) in

            guard newRoute != nil else {
                // TODO: Handle any errors here.
                return
            }

            // Optional: Do something with the route here.
        }
    }
}


extension WorkoutService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
        }

        guard !filteredLocations.isEmpty else { return }

        // Add the filtered data to the route.
        routeBuilder.insertRouteData(filteredLocations) { (success, error) in
            if !success {
                // TODO: Handle any errors here.
            }
        }
    }
}
