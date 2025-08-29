protocol DetailProtocol: AnyObject {
    func getModel()
}

protocol DetailPresenterProtocol: AnyObject {
    init(view: DetailProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol?)
    func fetchAllUsers(usersID: [String])
    func popVC()
    func showDetailOrgInfo(model: OrganizatorModel)
    func showBottomAlertForUser(model: UserModel)
    func showLocationOnMap(location: String)
}

final class DetailPresenter: DetailPresenterProtocol {

    weak var view: DetailProtocol?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?

    required init(view: DetailProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol?) {
        self.view = view
        self.router = router
        self.network = network
    }
    
    func fetchAllUsers(usersID: [String]) {
        network?.getAllUsersFromEvent(usersID: usersID, completion: { [weak self] result in
            guard let self = self else { return }
            
        })
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
