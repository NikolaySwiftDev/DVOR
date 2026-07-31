import CoreLocation

enum LocationCityError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case locationUnavailable
    case cityNotFound

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "registration.location_denied".loc
        case .authorizationRestricted:
            return "registration.location_restricted".loc
        case .locationUnavailable:
            return "registration.location_unavailable".loc
        case .cityNotFound:
            return "registration.city_not_found".loc
        }
    }
}

protocol LocationManagerProtocol: AnyObject {
    func requestCurrentCity(completion: @escaping (CityModel?, LocationCityError?) -> Void)
}

final class LocationManager: NSObject, LocationManagerProtocol {

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var cityCompletion: ((CityModel?, LocationCityError?) -> Void)?

    private var retryCount = 0
    private let maxRetries = 2

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Public

    func requestCurrentCity(completion: @escaping (CityModel?, LocationCityError?) -> Void) {
        cityCompletion = completion

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied:
            finish(nil, .authorizationDenied)
        case .restricted:
            finish(nil, .authorizationRestricted)
        @unknown default:
            finish(nil, .locationUnavailable)
        }
    }

    // MARK: - Private

    private func requestLocation() {
        retryCount = 0
        if let cached = manager.location, cached.timestamp.timeIntervalSinceNow > -300 {
            reverseGeocode(cached)
        }
        manager.requestLocation()
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }

            guard let placemark = placemarks?.first, let locality = placemark.locality else {
                DispatchQueue.main.async { self.finish(nil, .cityNotFound) }
                return
            }

            let city = CityModel(
                name: locality,
                countryCode: placemark.isoCountryCode ?? "",
                administrativeArea: placemark.administrativeArea,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )

            DispatchQueue.main.async { self.finish(city, nil) }
        }
    }

    private func finish(_ city: CityModel?, _ error: LocationCityError?) {
        cityCompletion?(city, error)
        cityCompletion = nil
    }

    deinit {
         print("Deinit LocationManager")
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard cityCompletion != nil else { return }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .denied:
            finish(nil, .authorizationDenied)
        case .restricted:
            finish(nil, .authorizationRestricted)
        case .notDetermined:
            break
        @unknown default:
            finish(nil, .locationUnavailable)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            finish(nil, .locationUnavailable)
            return
        }
        reverseGeocode(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError,
           clError.code == .locationUnknown,
           retryCount < maxRetries {
            retryCount += 1
            manager.requestLocation()
            return
        }
        finish(nil, .locationUnavailable)
    }
}
