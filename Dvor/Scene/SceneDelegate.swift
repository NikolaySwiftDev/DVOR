
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let navigationController = UINavigationController()
    private let builder = Builder()
    private lazy var router = Router(navigationController: navigationController,
                        builder: builder)
    
    private let firebaseDataManager = FirebaseDataManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        router.initialViewController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        if let urlContext = connectionOptions.urlContexts.first {
            handleDeepLink(urlContext: urlContext)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first else { return }
        handleDeepLink(urlContext: firstUrl)
    }
    
    private func handleDeepLink(urlContext: UIOpenURLContext) {
        guard let components = URLComponents(url: urlContext.url, resolvingAgainstBaseURL: true) else { return }
        
        switch components.host {
        case "openScreen":
            openDetailScreen(with: components.queryItems ?? [])
        default:
            break
        }
    }
    
    func openDetailScreen(with queryItems: [URLQueryItem]) {
        let screenQuery = queryItems.first(where: {$0.name == "screen"})
        switch screenQuery?.value {
        case "detail":
            guard let eventId = queryItems.first(where: { $0.name == "eventId" })?.value else {
                print("⚠️ Event ID not found in deep link")
                DispatchQueue.main.async {
                    self.router.showAlertWithTitle("⚠️ Event ID not found in deep link")
                }
                return
            }
            
            firebaseDataManager.fetchEvent(idEvent: eventId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let event):
                    let detailModel = event.toDetailModel()
                    DispatchQueue.main.async {
                        self.router.pushDetailVC(model: detailModel)
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.router.showAlertWithTitle(error.localizedDescription)
                    }
                    print("❌ Failed to fetch event: \(error.localizedDescription)")
                }
            }
            
        default:
            break
        }
    }
}
