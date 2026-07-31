protocol DetailOrgInfoProtocol: AnyObject {}

protocol DetailOrgInfoPresenterProtocol: AnyObject {
    init(view: DetailOrgInfoProtocol, router: RouterMainProtocol)
    func popVC()
}

final class DetailOrgInfoPresenter: DetailOrgInfoPresenterProtocol {
    weak var view: DetailOrgInfoProtocol?
    var router: RouterMainProtocol?
    
    required init(view: DetailOrgInfoProtocol, router: RouterMainProtocol) {
        self.view = view
        self.router = router
    }
    
    func popVC() {
//        router?.dismiss()
    }
    
    deinit {
         print("deinit DetailOrgInfoPresenterProtocol")
    }
}

