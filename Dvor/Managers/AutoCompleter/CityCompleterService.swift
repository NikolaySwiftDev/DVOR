import MapKit

struct SuggestionModel {
    let title: String
    let subtitle: String
}

protocol CityCompleterServiceProtocol: AnyObject {
    var delegate: CityCompleterServiceDelegate? { get set }
    
    func search(query: String)
    func selectCity(at index: Int, completionHandler: @escaping (String?) -> Void)
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
    
    func selectCity(at index: Int, completionHandler: @escaping (String?) -> Void) {
        guard completions.indices.contains(index) else {
            completionHandler(nil)
            return
        }
        
        let completion = completions[index]
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let placemark = response?.mapItems.first?.placemark,
                  let locality = placemark.locality else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            DispatchQueue.main.async { completionHandler(locality) }
        }
    }
    
    deinit {
        print("Deinit City competer Service")
    }
}

extension CityCompleterService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.filter { !$0.subtitle.isEmpty }
        
        let suggestions = completions.map { SuggestionModel(title: $0.title, subtitle: $0.subtitle) }
        delegate?.cityCompleterService(self, didUpdateResults: suggestions)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completions = []
        delegate?.cityCompleterService(self, didFailWithError: error)
    }
}
