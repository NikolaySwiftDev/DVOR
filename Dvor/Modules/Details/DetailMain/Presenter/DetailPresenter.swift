protocol DetailProtocol: AnyObject {
    func success(users: [UserModel], org: OrganizatorModel)
    func load()
    func updateUsers(model: [String])
    func error(error: String)
    
}

protocol DetailPresenterProtocol: AnyObject {
    init(view: DetailProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol?,
         firebase: FirebaseAuthManagerProtocol)
    
    var users: [UserModel]? { get set }
    var org: OrganizatorModel? { get set }
    
    func fetchAllUsers(usersID: [String], orgID: String)
    func addUserToEvent(idEvent: String)
    func shareEvent(eventID: String)
    
    func popVC()
    func showDetailOrgInfo(model: OrganizatorModel)
    func showBottomAlertForUser(model: UserModel)
    func showLocationOnMap(location: String)
}

final class DetailPresenter: DetailPresenterProtocol {

    
    weak var view: DetailProtocol?
    var users: [UserModel]?
    var org: OrganizatorModel?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let firebase: FirebaseAuthManagerProtocol

    required init(view: DetailProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol?,
                  firebase: FirebaseAuthManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
    }
    
    //MARK: - Получение всех пользователей события
    func fetchAllUsers(usersID: [String], orgID: String) {
        view?.load()
        network?.fetchAllUsersFromEvent(usersID: usersID, orgId: orgID, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let users, let org)):
                self.users = users
                self.org = org
                view?.success(users: users, org: org ?? OrganizatorModel())
            case .failure(let failure):
                view?.error(error: failure.localizedDescription)
                router?.showAlertWithTitle(failure.localizedDescription)
            }
        })
    }
    
    //MARK: - Добавление участника
    func addUserToEvent(idEvent: String) {
        guard idEvent != "" else {
            router?.showAlertWithTitle("Выберите событие")
            return
        }
        
        guard let idUser = firebase.currentUser?.uid else {
            router?.showAlertWithTitle("Добавьте аккаунт")
            return
        }
                
        network?.writeUserToEvent(idEvent: idEvent, idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                router?.showAlertWithTitle("Пользователь добавлен")
            case .failure(let error):
                router?.showAlertWithTitle("Ошибка сохранения")
                view?.error(error: error.localizedDescription)
            }
        })
    }
    
    func shareEvent(eventID: String) {
        let shareURL = "dvor://openScreen?screen=detail&eventId="
        let fullURL = shareURL + eventID
        view?.load()
        router?.showShareSheet(items: [fullURL])
//        view?.success(users: users ?? [], org: org ?? OrganizatorModel())
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
