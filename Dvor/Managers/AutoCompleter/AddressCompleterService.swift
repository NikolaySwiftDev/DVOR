import MapKit

protocol AddressCompleterServiceDelegate: AnyObject {
    func addressCompleterService(_ service: AddressCompleterService, didUpdateResults results: [SuggestionModel])
    func addressCompleterService(_ service: AddressCompleterService, didFailWithError error: Error)
}

enum AddressSelectionResult {
    case completed(address: String)
    case needsHouseNumber(textToFill: String)
    case invalid
}

protocol AddressCompleterServiceProtocol: AnyObject {
    var delegate: AddressCompleterServiceDelegate? { get set }
    var expectedCity: String { get set }

    func search(query: String)
    func selectAddress(at index: Int, completionHandler: @escaping (AddressSelectionResult) -> Void)
}

final class AddressCompleterService: NSObject, AddressCompleterServiceProtocol {

    weak var delegate: AddressCompleterServiceDelegate?
    var expectedCity: String

    private lazy var completer: MKLocalSearchCompleter = {
        let c = MKLocalSearchCompleter()
        c.delegate = self
        c.resultTypes = .address
        return c
    }()

    private var completions: [MKLocalSearchCompletion] = []

    init(expectedCity: String = "") {
        self.expectedCity = expectedCity
    }

    func search(query: String) {
        let prefix = expectedCity.isEmpty ? "" : "\(expectedCity), "
        completer.queryFragment = prefix + query
    }

    func selectAddress(at index: Int, completionHandler: @escaping (AddressSelectionResult) -> Void) {
        guard completions.indices.contains(index) else {
            completionHandler(.invalid)
            return
        }

        let completion = completions[index]
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { [weak self] response, error in
            guard let self else { return }

            guard let placemark = response?.mapItems.first?.placemark,
                  let locality = placemark.locality,
                  locality.caseInsensitiveCompare(self.expectedCity) == .orderedSame,
                  let street = placemark.thoroughfare else {
                DispatchQueue.main.async { completionHandler(.invalid) }
                return
            }

            if let number = placemark.subThoroughfare {
                let fullAddress = "\(street), \(number)"
                DispatchQueue.main.async { completionHandler(.completed(address: fullAddress)) }
            } else {
                DispatchQueue.main.async { completionHandler(.needsHouseNumber(textToFill: street)) }
            }
        }
    }

    private func isLikelyStreet(_ completion: MKLocalSearchCompletion) -> Bool {
        let title = completion.title.trimmingCharacters(in: .whitespaces)

        if title.caseInsensitiveCompare(expectedCity) == .orderedSame {
            return false
        }

        guard title.rangeOfCharacter(from: .letters) != nil else {
            return false
        }

        return true
    }

    private func cleanedSubtitle(_ completion: MKLocalSearchCompletion) -> String {
        guard !expectedCity.isEmpty else { return completion.subtitle }

        var subtitle = completion.subtitle
        if let range = subtitle.range(of: expectedCity, options: .caseInsensitive) {
            subtitle.removeSubrange(range)
        }

        subtitle = subtitle.trimmingCharacters(in: CharacterSet(charactersIn: ", ").union(.whitespaces))
        return subtitle
    }
}

extension AddressCompleterService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let filtered = completer.results.filter { isLikelyStreet($0) }
        completions = deduplicated(filtered)

        let suggestions = completions.map {
            SuggestionModel(title: $0.title, subtitle: cleanedSubtitle($0))
        }
        delegate?.addressCompleterService(self, didUpdateResults: suggestions)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completions = []
        delegate?.addressCompleterService(self, didFailWithError: error)
    }

    private func deduplicated(_ completions: [MKLocalSearchCompletion]) -> [MKLocalSearchCompletion] {
        var seenTitles = Set<String>()
        var result: [MKLocalSearchCompletion] = []

        for completion in completions {
            let key = completion.title.trimmingCharacters(in: .whitespaces).lowercased()
            guard !seenTitles.contains(key) else { continue }
            seenTitles.insert(key)
            result.append(completion)
        }

        return result
    }
}
