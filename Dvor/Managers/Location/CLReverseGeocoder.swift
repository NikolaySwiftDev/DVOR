
import Foundation
import CoreLocation

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

protocol ReverseGeocoding: AnyObject {
    func address(for coordinate: Coordinate, completion: @escaping (String?) -> Void)
    func cancel()
}


final class CLReverseGeocoder: ReverseGeocoding {

    private let geocoder = CLGeocoder()

    func address(for coordinate: Coordinate, completion: @escaping (String?) -> Void) {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                guard error == nil,
                      let placemark = placemarks?.first,
                      let street = placemark.thoroughfare,
                      !street.isEmpty else {
                    completion(nil)
                    return
                }

                var address = street

                if let house = placemark.subThoroughfare, !house.isEmpty {
                    address += ", \(house)"
                }

                completion(address)
            }
        }
    }

    func cancel() {
        geocoder.cancelGeocode()
    }

    deinit {
        geocoder.cancelGeocode()
    }
}
