import MapKit

struct SuggestionModel {
    let title: String
    let subtitle: String
}

protocol CityCompleterServiceProtocol: AnyObject {
    var delegate: CityCompleterServiceDelegate? { get set }
    
    func search(query: String)
    func selectCity(at index: Int, completionHandler: @escaping (CityModel?) -> Void)
}

protocol CityCompleterServiceDelegate: AnyObject {
    func cityCompleterService(_ service: CityCompleterService, didUpdateResults results: [SuggestionModel])
    func cityCompleterService(_ service: CityCompleterService, didFailWithError error: Error)
}

final class CityCompleterService: NSObject, CityCompleterServiceProtocol {
    
    weak var delegate: CityCompleterServiceDelegate?
    
    private lazy var completer: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.resultTypes = .address
        return completer
    }()
    
    private var completions: [MKLocalSearchCompletion] = []
    
    func search(query: String) {
        completer.queryFragment = query
    }
    
    func selectCity(at index: Int, completionHandler: @escaping (CityModel?) -> Void) {
        guard completions.indices.contains(index) else {
            completionHandler(nil)
            return
        }

        let completion = completions[index]
        let request = MKLocalSearch.Request(completion: completion)

        MKLocalSearch(request: request).start { response, error in
            guard let placemark = response?.mapItems.first?.placemark else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }

            guard placemark.thoroughfare == nil,
                  let locality = placemark.locality else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }

            let city = CityModel(
                name: locality,
                countryCode: placemark.countryCode ?? "",
                administrativeArea: placemark.administrativeArea,
                latitude: placemark.coordinate.latitude,
                longitude: placemark.coordinate.longitude
            )

            DispatchQueue.main.async { completionHandler(city) }
        }
    }
    
    deinit {
        // print("Deinit City competer Service")
    }
}

extension CityCompleterService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.filter { result in
            guard !result.subtitle.isEmpty else { return false }
            let looksLikeCity = !result.subtitle.contains(",")
            return looksLikeCity
        }
        
        let suggestions = completions.map { SuggestionModel(title: $0.title, subtitle: $0.subtitle) }
        delegate?.cityCompleterService(self, didUpdateResults: suggestions)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completions = []
        delegate?.cityCompleterService(self, didFailWithError: error)
    }
}

struct CityModel: Equatable, Codable {
    let name: String
    let countryCode: String
    let administrativeArea: String?
    let latitude: Double
    let longitude: Double
    
    private static let sameCityRadius: CLLocationDistance = 30_000

    static func == (lhs: CityModel, rhs: CityModel) -> Bool {
        let location1 = CLLocation(latitude: lhs.latitude, longitude: lhs.longitude)
        let location2 = CLLocation(latitude: rhs.latitude, longitude: rhs.longitude)
        return location1.distance(from: location2) < sameCityRadius
    }
}

let mockCity = CityModel(name: "", countryCode: "", administrativeArea: "", latitude: 0, longitude: 0)
