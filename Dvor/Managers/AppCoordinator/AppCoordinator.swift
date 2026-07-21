import UIKit

final class AppCoordinator {

    private let window: UIWindow

    private let navigationController = UINavigationController()
    private let builder = Builder()
    private let firebaseDataManager = FirebaseDataManager()
    
    private lazy var rootController = RootController(window: window)

    private lazy var router = Router(
        navigationController: navigationController,
        builder: builder,
        rootController: rootController
    )

    private lazy var deepLinkHandler: DeepLinkHandlerProtocol = {
        DeepLinkHandler(
            router: router,
            firebaseDataManager: firebaseDataManager
        )
    }()

    private let offlineAlertController = OfflineAlertController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        window.rootViewController = navigationController
        router.initialViewController()
        offlineAlertController.start(window: window)
    }

    func handle(url: URL) {
        let deepLink = DeepLink.parse(from: url)
        deepLinkHandler.handle(deepLink)
    }
}

import UIKit

final class RootController {

    private weak var window: UIWindow?

    init(window: UIWindow) {
        self.window = window
    }

    func setRoot(_ vc: UIViewController) {

        guard let window else { return }

       

        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve, animations: {
                window.rootViewController = vc
            }
        )
    }
}
