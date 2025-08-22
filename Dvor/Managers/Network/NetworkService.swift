import Foundation

protocol NetworkServiceProtocol: AnyObject {
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        return decoder
    }()

    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void) {
        guard let url = Bundle.main.url(forResource: "Events", withExtension: "json") else {
            completion(.failure(NSError(domain: "LocalFile", code: 404, userInfo: [NSLocalizedDescriptionKey: "events.json not found"])))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let events = try decoder.decode([EventModel].self, from: data)
            completion(.success(events))
        } catch {
            completion(.failure(error))
        }
    }
}
