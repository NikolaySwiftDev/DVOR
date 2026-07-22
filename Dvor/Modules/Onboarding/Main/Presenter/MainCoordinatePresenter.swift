import Foundation

protocol MainCoordinatePresenterProtocol: AnyObject {
    init(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol)

    func pushRegistVC()
    func pushMainView()
}

final class MainCoordinatePresenter: MainCoordinatePresenterProtocol {

    private let router: RouterMainProtocol
    private weak var coordinator: AppCoordinatorProtocol?

    init(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol) {
        self.router = router
        self.coordinator = coordinator
    }

    func pushMainView() {
        coordinator?.showHome()
    }

    func pushRegistVC() {
        coordinator?.showOnboarding()
    }
}
