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

    private let completer = MKLocalSearchCompleter()
    private var completions: [MKLocalSearchCompletion] = []
    private var debounceWorkItem: DispatchWorkItem?
    private var selectSearch: MKLocalSearch?

    // MARK: - Init

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    // MARK: - CityCompleterServiceProtocol

    func search(query: String) {
        debounceWorkItem?.cancel()

        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard query.count >= 2 else {
            completer.cancel()
            completions = []
            delegate?.cityCompleterService(self, didUpdateResults: [])
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.completer.queryFragment = query
        }

        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    func selectCity(at index: Int, completionHandler: @escaping (CityModel?) -> Void) {
        guard completions.indices.contains(index) else {
            completionHandler(nil)
            return
        }

        selectSearch?.cancel()

        let search = MKLocalSearch(request: MKLocalSearch.Request(completion: completions[index]))
        selectSearch = search

        search.start { response, _ in
            DispatchQueue.main.async {
                guard let placemark = response?.mapItems.first?.placemark,
                      let locality = placemark.locality, !locality.isEmpty
                else {
                    completionHandler(nil)
                    return
                }

                let city = CityModel(
                    name: locality,
                    countryCode: placemark.countryCode ?? "",
                    administrativeArea: placemark.administrativeArea,
                    latitude: placemark.coordinate.latitude,
                    longitude: placemark.coordinate.longitude
                )

                completionHandler(city)
            }
        }
    }

    // MARK: - Private

    private func isLikelyCity(_ completion: MKLocalSearchCompletion) -> Bool {
        // Улицы и дома почти всегда содержат цифры
        let hasDigits: (String) -> Bool = { $0.rangeOfCharacter(from: .decimalDigits) != nil }
        return !hasDigits(completion.title) && !hasDigits(completion.subtitle)
    }

    private func deduplicate(_ items: [MKLocalSearchCompletion]) -> [MKLocalSearchCompletion] {
        var unique = Set<String>()

        return items.filter {
            unique.insert("\(normalize($0.title))_\(normalize($0.subtitle))").inserted
        }
    }

    private func sort(_ items: [MKLocalSearchCompletion], query: String) -> [MKLocalSearchCompletion] {
        let normalizedQuery = normalize(query)

        return items.sorted {
            let lhs = normalize($0.title)
            let rhs = normalize($1.title)

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

    private func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }

    deinit {
        debounceWorkItem?.cancel()
        completer.cancel()
        selectSearch?.cancel()
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension CityCompleterService: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let filtered = completer.results.filter(isLikelyCity)
        let prepared = sort(deduplicate(filtered), query: completer.queryFragment)

        completions = Array(prepared.prefix(8))

        let suggestions = completions.map {
            SuggestionModel(title: $0.title, subtitle: $0.subtitle)
        }

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
