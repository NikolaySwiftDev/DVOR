import Network
import Foundation

// MARK: - Notification

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

// MARK: - Error

enum NetworkError: LocalizedError {
    case offline

    var errorDescription: String? {
        switch self {
        case .offline:
            return "network.offline_error".loc
        }
    }
}

// MARK: - Protocol

protocol NetworkMonitorProtocol: AnyObject {
    var isConnected: Bool { get }
    var isExpensive: Bool { get }

    func startMonitoring()
    func stopMonitoring()
    func checkConnection(completion: @escaping (Bool) -> Void)
}

// MARK: - NetworkMonitor
final class NetworkMonitor: NetworkMonitorProtocol {

    static let shared = NetworkMonitor()

    static let isConnectedKey = "isConnected"

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.dvor.networkMonitor")

    private(set) var isConnected: Bool = true
    private(set) var isExpensive: Bool = false

    private init() {}

    // MARK: - Public

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let connected = path.status == .satisfied
            let expensive = path.isExpensive

            DispatchQueue.main.async {
                let didChange = self.isConnected != connected
                self.isConnected = connected
                self.isExpensive = expensive

                if didChange {
                    NotificationCenter.default.post(
                        name: .networkStatusChanged,
                        object: self,
                        userInfo: [NetworkMonitor.isConnectedKey: connected]
                    )
                }
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    func checkConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.apple.com") else {
            completion(isConnected)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            let success = error == nil && (response as? HTTPURLResponse)?.statusCode == 200

            DispatchQueue.main.async {
                guard let self else {
                    completion(success)
                    return
                }

                let didChange = self.isConnected != success
                self.isConnected = success

                if didChange {
                    NotificationCenter.default.post(
                        name: .networkStatusChanged,
                        object: self,
                        userInfo: [NetworkMonitor.isConnectedKey: success]
                    )
                }

                completion(success)
            }
        }
        task.resume()
    }

    deinit {
        print("Deinit NetworkMonitor")
    }
}
