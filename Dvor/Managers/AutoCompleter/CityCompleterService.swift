import MapKit

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

    // MARK: - Properties

    weak var delegate: CityCompleterServiceDelegate?

    private var searchWorkItem: DispatchWorkItem?
    private var searchTask: MKLocalSearch?
    private var cities: [CityModel] = []

    // MARK: - Search

    func search(query: String) {
        searchWorkItem?.cancel()
        searchTask?.cancel()

        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard query.count >= 2 else {
            cities = []
            delegate?.cityCompleterService(self, didUpdateResults: [])
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: query)
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }

    func selectCity(at index: Int, completionHandler: @escaping (CityModel?) -> Void) {
        guard cities.indices.contains(index) else {
            completionHandler(nil)
            return
        }

        completionHandler(cities[index])
    }

    // MARK: - Private

    private func performSearch(query: String) {
        searchTask?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        searchTask = search

        search.start { [weak self] response, error in
            guard let self else { return }

            DispatchQueue.main.async {
                guard error == nil else {
                    self.cities = []
                    self.delegate?.cityCompleterService(self, didFailWithError: error!)
                    return
                }

                let cities = self.extractCities(from: response?.mapItems ?? [], query: query)
                self.cities = cities

                let suggestions = cities.map { SuggestionModel(title: $0.name, subtitle: self.makeSubtitle(for: $0)) }

                self.delegate?.cityCompleterService(self, didUpdateResults: suggestions)
            }
        }
    }

    private func extractCities(from mapItems: [MKMapItem], query: String) -> [CityModel] {
        var result: [CityModel] = []
        var uniqueCities = Set<String>()

        for mapItem in mapItems {
            guard let locality = mapItem.placemark.locality, !locality.isEmpty else { continue }

            let placemark = mapItem.placemark
            let city = CityModel(name: locality, countryCode: placemark.countryCode ?? "", administrativeArea: placemark.administrativeArea, latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
            let key = "\(normalize(locality))_\(placemark.countryCode ?? "")"

            guard uniqueCities.insert(key).inserted else { continue }

            result.append(city)
        }

        return sortCities(result, query: query)
    }

    private func sortCities(_ cities: [CityModel], query: String) -> [CityModel] {
        let normalizedQuery = normalize(query)

        return cities.sorted {
            let lhs = normalize($0.name)
            let rhs = normalize($1.name)

            let lhsExact = lhs == normalizedQuery
            let rhsExact = rhs == normalizedQuery

            if lhsExact != rhsExact {
                return lhsExact
            }

            let lhsStarts = lhs.hasPrefix(normalizedQuery)
            let rhsStarts = rhs.hasPrefix(normalizedQuery)

            if lhsStarts != rhsStarts {
                return lhsStarts
            }

            return lhs < rhs
        }
    }

    private func makeSubtitle(for city: CityModel) -> String {
        [city.administrativeArea, countryName(for: city.countryCode)].compactMap { $0 }.joined(separator: ", ")
    }

    private func countryName(for countryCode: String) -> String? {
        guard !countryCode.isEmpty else { return nil }

        return Locale.current.localizedString(forRegionCode: countryCode.uppercased())
    }

    private func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }

    deinit {
        searchWorkItem?.cancel()
        searchTask?.cancel()
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
