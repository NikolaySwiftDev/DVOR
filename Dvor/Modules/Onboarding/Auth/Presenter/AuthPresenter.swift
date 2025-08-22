import Foundation
protocol AuthProtocol: AnyObject {
}

protocol AuthPresenterProtocol: AnyObject {
    func pushRegistVC()
    func pushMainView()
    init(view: AuthProtocol, router: RouterMainProtocol, userDefaults: UserDefaultsProtocol)
}

final class AuthPresenter: AuthPresenterProtocol {
    weak var view: AuthProtocol?
    let userDefaults: UserDefaultsProtocol?
    let router: RouterMainProtocol?

    required init(view: AuthProtocol, router: RouterMainProtocol, userDefaults: UserDefaultsProtocol) {
        self.view = view
        self.userDefaults = userDefaults
        self.router = router
    }
    
    func pushMainView() {
        router?.pushTabBarVC()
    }
    
    func pushRegistVC() {
        router?.pushRegistVC()
    }
    
    deinit {
        print("Auth Presenter deinit")
    }
}

