import MapKit

protocol AddressCompleterServiceDelegate: AnyObject {
    func addressCompleterService(_ service: AddressCompleterService, didUpdateResults results: [SuggestionModel])
    func addressCompleterService(_ service: AddressCompleterService, didFailWithError error: Error)
}

protocol AddressCompleterServiceProtocol: AnyObject {
    var delegate: AddressCompleterServiceDelegate? { get set }
    var expectedCity: String { get set }
    
    func search(query: String)
    func selectAddress(at index: Int, completionHandler: @escaping (String?) -> Void)
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
    
    func selectAddress(at index: Int, completionHandler: @escaping (String?) -> Void) {
        guard completions.indices.contains(index) else {
            completionHandler(nil)
            return
        }
        
        let completion = completions[index]
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, error in
            guard let self else { return }
            
            guard let placemark = response?.mapItems.first?.placemark,
                  let locality = placemark.locality,
                  locality.caseInsensitiveCompare(self.expectedCity) == .orderedSame else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            let street = placemark.thoroughfare
            let number = placemark.subThoroughfare
            let fullAddress = [street, number].compactMap { $0 }.joined(separator: ", ")
            let result = fullAddress.isEmpty ? placemark.name : fullAddress
            
            DispatchQueue.main.async { completionHandler(result) }
        }
    }
}

extension AddressCompleterService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
        
        let suggestions = completions.map { SuggestionModel(title: $0.title, subtitle: $0.subtitle) }
        delegate?.addressCompleterService(self, didUpdateResults: suggestions)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completions = []
        delegate?.addressCompleterService(self, didFailWithError: error)
    }
}
