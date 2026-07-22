import UIKit

protocol AppCoordinatorProtocol: AnyObject {
    func start()
    func showHome()
    func showOnboarding()
}

final class AppCoordinator: AppCoordinatorProtocol {

    // MARK: - Properties
    private var registrationCoordinator: RegistrationCoordinator?
    private var interactivePopGestureHandler: InteractivePopGestureHandler?
    private let rootController: RootController
    private let window: UIWindow
    private let builder = Builder()
    private let firebase = MockFirebaseAuthManager()
    private let firebaseDataManager = FirebaseDataManager()

    private let offlineAlertController = OfflineAlertController()


    private(set) lazy var router: Router = {
        Router(
            navigationController: UINavigationController(),
            builder: builder
        )
    }()

    private lazy var deepLinkHandler: DeepLinkHandlerProtocol = {
        DeepLinkHandler(
            router: router,
            firebaseDataManager: firebaseDataManager
        )
    }()

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
        self.rootController = RootController(window: window)
    }

    // MARK: - Public

    func start() {
        if firebase.isAuthorized {
            showHome()
        } else {
            showOnboarding()
        }
        offlineAlertController.start(window: window)
    }

    func showHome() {
        let vc = builder.createHomeVC(router: router, coordinator: self)
        setRoot(vc)
    }

    func showOnboarding() {
        let presenter = builder.createRegistrationCoordinator(router: router)
        registrationCoordinator = RegistrationCoordinator(presenter: presenter, window: window, router: router)
        registrationCoordinator?.onRegistrationComplete = { [weak self] in
            guard let self = self else { return }
            registrationCoordinator = nil
            showHome()
        }
        registrationCoordinator?.start()
    }
    // MARK: - Private

    private func setRoot(_ root: UIViewController) {

        let navigation = UINavigationController(rootViewController: root)
        navigation.setNavigationBarHidden(true, animated: false)
        
        interactivePopGestureHandler = InteractivePopGestureHandler(navigationController: navigation)

        router.navigationController = navigation
        rootController.setRoot(navigation)
    }
    
    func handle(url: URL) {
        let deepLink = DeepLink.parse(from: url)
        deepLinkHandler.handle(deepLink)
    }
}

