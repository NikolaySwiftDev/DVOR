import CoreLocation

func makeCoordinate(latitude: Double, longitude: Double) -> CLLocationCoordinate2D {
    CLLocationCoordinate2D(
        latitude: latitude,
        longitude: longitude
    )
}

func isSameCity(city1: String, countryCode1: String, administrativeArea1: String?, city2: String, countryCode2: String,  administrativeArea2: String?) -> Bool {

    guard countryCode1.caseInsensitiveCompare(countryCode2) == .orderedSame else {
        return false
    }

    guard city1.caseInsensitiveCompare(city2) == .orderedSame else {
        return false
    }

    if let area1 = administrativeArea1,
       let area2 = administrativeArea2 {
        return area1.caseInsensitiveCompare(area2) == .orderedSame
    }

    return true
}
