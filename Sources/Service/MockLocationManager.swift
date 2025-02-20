import CoreLocation

@Observable
public class MockLocationManager: NSObject, LocationManagerProtocol {
    public var location: CLLocation?
    public var authStatus: CLAuthorizationStatus? = .authorizedWhenInUse

    private var updateTimer: Timer?

    public override init() {
        super.init()
        startUpdatingLocation()
        location = CLLocation(
            latitude: 37.7749,
            longitude: -122.4194
        )
    }

    /// タイマーで5秒ごとに位置情報の更新をシミュレーションします。
    public func startUpdatingLocation() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let baseLatitude = 37.7749
            let baseLongitude = -122.4194
            let randomLatitude = baseLatitude + Double.random(in: -0.001...0.001)
            let randomLongitude = baseLongitude + Double.random(in: -0.001...0.001)
            self.location = CLLocation(latitude: randomLatitude, longitude: randomLongitude)
        }
    }
}
