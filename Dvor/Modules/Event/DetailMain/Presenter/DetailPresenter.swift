protocol DetailProtocol: AnyObject {
    func success(users: [UserModel], org: OrganizatorModel)
    func load()
    func updateUsers(model: [String])
    func error(error: String)
}

protocol DetailPresenterProtocol: AnyObject {
    init(view: DetailProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol?, userDefaults: UserDefaultsProtocol?)
    var users: [UserModel]? { get set }
    func fetchAllUsers(usersID: [String], orgID: String)
    func addUserToEvent(idEvent: String)
    func popVC()
    func showDetailOrgInfo(model: OrganizatorModel)
    func showBottomAlertForUser(model: UserModel)
    func showLocationOnMap(location: String)
}

final class DetailPresenter: DetailPresenterProtocol {
    
    weak var view: DetailProtocol?
    var users: [UserModel]?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let userDefaults: UserDefaultsProtocol?

    required init(view: DetailProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol?, userDefaults: UserDefaultsProtocol?) {
        self.view = view
        self.router = router
        self.network = network
        self.userDefaults = userDefaults
    }
    
    //MARK: - Получение всех пользователей события
    func fetchAllUsers(usersID: [String], orgID: String) {
        view?.load()
        network?.getAllUsersFromEvent(usersID: usersID, orgId: orgID, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let users, let org)):
                self.users = users
                view?.success(users: users, org: org ?? OrganizatorModel(id: "", image: nil, name: ""))
            case .failure(let failure):
                view?.error(error: failure.localizedDescription)
                router?.showErrorAlerWithTitle(failure.localizedDescription)
            }
        })
    }
    
    //MARK: - Добавление участника
    func addUserToEvent(idEvent: String) {
        guard idEvent != "" else {
            router?.showErrorAlerWithTitle("Выберите событие")
            return
        }
        
        guard let idUser = userDefaults?.getIDUser() else {
            router?.showErrorAlerWithTitle("Добавьте аккаунт")
            return
        }
                
        network?.addUserToEvent(idEvent: idEvent, idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                router?.showErrorAlerWithTitle("Пользователь добавлен")
            case .failure(let error):
                router?.showErrorAlerWithTitle("Ошибка сохранения")
                view?.error(error: error.localizedDescription)
            }
        })
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
    
    func popVC() {
        router?.popVC()
    }
    
    deinit {
        print("Deinit Detail Presenter")
    }
}
