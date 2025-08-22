protocol DetailProtocol: AnyObject {
    func getModel()
}

protocol DetailPresenterProtocol: AnyObject {
    init(view: DetailProtocol, router: RouterMainProtocol)
    func popVC()
    func showDetailOrgInfo(model: OrganizatorModel)
    func showBottomAlertForUser(model: UserModel)
    func showLocationOnMap(location: String)
}

final class DetailPresenter: DetailPresenterProtocol {

    weak var view: DetailProtocol?
    let router: RouterMainProtocol?

    required init(view: DetailProtocol, router: RouterMainProtocol) {
        self.view = view
        self.router = router
    }
    
    func popVC() {
        router?.popVC()
    }

    func showBottomAlertForUser(model: UserModel) {
        router?.showBottomSheetAlertForUser(model: model)
    }
    
    func showLocationOnMap(location: String) {
        router?.showLocationOnMap(location: location)
    }
    
    func showDetailOrgInfo(model: OrganizatorModel) {
        router?.pushDetailOrgInfo(model: model)
    }
    
    deinit {
        print("Deinit Detail Presenter")
    }
}
