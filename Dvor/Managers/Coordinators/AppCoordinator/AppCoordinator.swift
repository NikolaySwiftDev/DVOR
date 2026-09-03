import UIKit

protocol AppCoordinatorProtocol: AnyObject {
    func start()
    func showHome()
    func showOnboarding()
    func showRegistration()
}

final class AppCoordinator: AppCoordinatorProtocol {

    // MARK: - Properties
    private let window: UIWindow
    
    private let builder: BuilderProtocol
    private var registrationCoordinator: RegistrationCoordinator?
    private var interactivePopGestureHandler: InteractivePopGestureHandler?
    private let rootController: RootController

    private let authManager: FirebaseAuthManagerProtocol
    private let dataManager: FirebaseDataManagerProtocol

    private let offlineAlertController = OfflineAlertController()

    private(set) lazy var router: Router = {
        let router = Router(
            navigationController: UINavigationController(),
            builder: builder
        )
        router.appCoordinator = self
        return router
    }()

    private lazy var deepLinkHandler: DeepLinkHandlerProtocol = {
        DeepLinkHandler(
            router: router,
            firebaseDataManager: dataManager
        )
    }()

    // MARK: - Init

    init(window: UIWindow, builder: BuilderProtocol, authManager: FirebaseAuthManagerProtocol, dataManager: FirebaseDataManagerProtocol) {
        self.window = window
        self.builder = builder
        self.rootController = RootController(window: window)
        self.authManager = authManager
        self.dataManager = dataManager
    }

    // MARK: - Public

    func start() {
        if authManager.isAuthorized {
            showHome()
        } else {
            showRegistration()
        }
        offlineAlertController.start(window: window)
    }

    func showHome() {
        let vc = builder.createHomeVC(router: router)
        setRoot(vc)
    }
    
    func showRegistration() {
        let vc = builder.createRegistration(router: router)
        setRoot(vc)
    }

    func showOnboarding() {
        let presenter = builder.createRegistrationPresenter(router: router, coordinator: self)
        registrationCoordinator = RegistrationCoordinator(presenter: presenter, rootController: rootController, router: router)
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
    
    deinit {
//        print(#function + "AppCoordinator")
    }
}
