import Foundation
import UIKit

// MARK: - Deep Link Types
enum DeepLink {
    case detailEvent(eventId: String)
    case unknown
    
    static func parse(from url: URL) -> DeepLink {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return .unknown
        }
        
        let queryItems = components.queryItems ?? []
        
        switch components.host {
        case DeepLinkConstants.Host.openScreen:
            return parseOpenScreen(queryItems: queryItems)
        default:
            return .unknown
        }
    }
    
    private static func parseOpenScreen(queryItems: [URLQueryItem]) -> DeepLink {
        let screenQuery = queryItems.first(where: { $0.name == DeepLinkConstants.QueryKey.screen })
        
        switch screenQuery?.value {
        case DeepLinkConstants.Screen.detail:
            if let eventId = queryItems.first(where: { $0.name == DeepLinkConstants.QueryKey.eventId })?.value {
                return .detailEvent(eventId: eventId)
            }
            return .unknown
        default:
            return .unknown
        }
    }
}

// MARK: - Deep Link Constants
enum DeepLinkConstants {
    enum Host {
        static let openScreen = "openScreen"
    }
    
    enum Screen {
        static let detail = "detail"
    }
    
    enum QueryKey {
        static let screen = "screen"
        static let eventId = "eventId"
    }
}

// MARK: - Deep Link Handler Protocol
protocol DeepLinkHandlerProtocol {
    func handle(_ deepLink: DeepLink)
}

// MARK: - Deep Link Handler Implementation
final class DeepLinkHandler: DeepLinkHandlerProtocol {
    
    private let router: RouterMainProtocol
    private let firebaseDataManager: FirebaseDataManager
    
    init(router: RouterMainProtocol, firebaseDataManager: FirebaseDataManager) {
        self.router = router
        self.firebaseDataManager = firebaseDataManager
    }
    
    func handle(_ deepLink: DeepLink) {
        switch deepLink {
        case .detailEvent(let eventId):
            handleDetailEvent(eventId: eventId)
        case .unknown:
            print("⚠️ Unknown deep link")
        }
    }
    
    // MARK: - Private Methods
    private func handleDetailEvent(eventId: String) {
        firebaseDataManager.fetchEvent(idEvent: eventId) { [weak self] result in
            guard let self = self else { return }
            
            self.executeOnMainThread {
                switch result {
                case .success(let event):
                    let detailModel = event.toDetailModel()
                    self.router.pushDetailVC(model: detailModel)
                    
                case .failure(let error):
                    self.router.showAlertWithTitle(error.localizedDescription)
                    print("❌ Failed to fetch event: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func executeOnMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
