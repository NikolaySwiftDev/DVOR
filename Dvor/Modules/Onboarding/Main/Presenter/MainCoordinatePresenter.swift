import Foundation

protocol MainCoordinatePresenterProtocol: AnyObject {
    init(router: RouterMainProtocol)
    func pushRegistVC()
//    func pushAuthVC()
    func pushMainView()
}

final class MainCoordinatePresenter: MainCoordinatePresenterProtocol {
    let router: RouterMainProtocol?

    required init(router: RouterMainProtocol) {
        self.router = router
    }
    
    func pushMainView() {
        router?.pushTabBarVC()
    }
    
    func pushRegistVC() {
        router?.pushRegistVC()
    }
    
//    func pushAuthVC() {
//        router?.pushAuthVC()
//    }
    
    deinit {
        print("Auth Presenter deinit")
    }
}

