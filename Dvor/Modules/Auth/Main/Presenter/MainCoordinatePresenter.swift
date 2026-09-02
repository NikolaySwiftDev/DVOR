import Foundation

protocol MainCoordinatePresenterProtocol: AnyObject {
    init(router: RouterMainProtocol)
    func pushRegistVC()
    func pushMainView()
    func pushAuthVC()
}

final class MainCoordinatePresenter: MainCoordinatePresenterProtocol {
    let router: RouterMainProtocol?

    required init(router: RouterMainProtocol) {
        self.router = router
    }
    
    func pushMainView() {
        router?.pushHomeVC()
    }
    
    func pushRegistVC() {
        router?.pushRegistVC()
    }
    
    func pushAuthVC() {
        router?.pushAuthVC()
    }
    
    deinit {
        print("Auth Presenter deinit")
    }
}

