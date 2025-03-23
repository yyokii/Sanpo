import CoreLocation

public protocol LocationManagerProtocol {
    var location: CLLocation? { get }
    var authStatus: CLAuthorizationStatus? { get }
}

@Observable
public class LocationManager: NSObject, LocationManagerProtocol {
    static public let shared = LocationManager()

    private let locationManager = CLLocationManager()

    public var location: CLLocation?
    public var authStatus: CLAuthorizationStatus?

    override private init() {
        super.init()
        locationManager.delegate = self
    }

    // TODO: 初回で位置情報の取得許可を求める
    public func requestWhenInUseAuthorization() {
        guard locationManager.authorizationStatus == .notDetermined else {
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }

    public func requestLocation() {
        guard locationManager.authorizationStatus == .authorizedAlways ||
                locationManager.authorizationStatus == .authorizedWhenInUse
        else {
            return
        }

        locationManager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}
