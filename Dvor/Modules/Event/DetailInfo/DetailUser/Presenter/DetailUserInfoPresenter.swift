protocol DetailUserInfoProtocol: AnyObject {}

protocol DetailUserInfoPresenterProtocol: AnyObject {
    init(view: DetailUserInfoProtocol, router: RouterMainProtocol)
    func popVC()
    func followUser()
}

final class DetailUserInfoPresenter: DetailUserInfoPresenterProtocol {
    weak var view: DetailUserInfoProtocol?
    var router: RouterMainProtocol?
    
    required init(view: DetailUserInfoProtocol, router: RouterMainProtocol) {
        self.view = view
        self.router = router
    }
    
    func popVC() {
        router?.popVC()
    }
    
    func followUser() {
        print("User followed")
    }
    
    deinit {
        print("deinit DetailUserInfoPresenterProtocol")
    }
}

