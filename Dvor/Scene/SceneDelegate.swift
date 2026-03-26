
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?
    
    private let navigationController = UINavigationController()
    private let builder = Builder()
    private let firebaseDataManager = FirebaseDataManager()
    
    private lazy var router: Router = {
        Router(navigationController: navigationController, builder: builder)
    }()
    
    private lazy var deepLinkHandler: DeepLinkHandlerProtocol = {
        DeepLinkHandler(router: router, firebaseDataManager: firebaseDataManager)
    }()

    // MARK: - Scene Lifecycle
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        setupWindow(with: windowScene)
        
        // Handle deep link if app was opened with URL
        if let urlContext = connectionOptions.urlContexts.first {
            handleDeepLink(from: urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(from: url)
    }
    
    // MARK: - Private Methods
    private func setupWindow(with windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        
        router.initialViewController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    private func handleDeepLink(from url: URL) {
        let deepLink = DeepLink.parse(from: url)
        deepLinkHandler.handle(deepLink)
    }
}
