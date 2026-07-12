import Foundation

protocol DetailProtocol: AnyObject {
    func success(users: [UserModel], org: OrganizatorModel)
    func load()
    func updateUsers(model: [String])
    func error(error: String)
    func hideLoading()
}

protocol DetailPresenterProtocol: AnyObject {
    init(view: DetailProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol?,
         firebase: FirebaseAuthManagerProtocol,
         notification: NotificationManagerProtocol
    )
    
    var users: [UserModel]? { get set }
    var org: OrganizatorModel? { get set }
    
    func fetchAllUsers(usersID: [String], orgID: String)
    func addUserToEvent(idEvent: String, date: Date, isComplete: Bool)
    func removeUserFromEvent(idEvent: String)
    
    func popVC()
    func shareEvent(eventID: String)
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
    let notification: NotificationManagerProtocol

    required init(view: DetailProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol?,
                  firebase: FirebaseAuthManagerProtocol,
                  notification: NotificationManagerProtocol
    ) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
        self.notification = notification
    }
    
    //MARK: - Fetch all users
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
    
    //MARK: - Add user
    func addUserToEvent(idEvent: String, date: Date, isComplete: Bool) {
        guard idEvent != "" else {
            router?.showAlertWithTitle(DetailPresenterConstants.selectEvent)
            return
        }
        
//        guard let idUser = firebase.currentUser?.uid else {
        guard let idUser = firebase.currentUserId else {
            router?.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }
        
        if let users = users, users.contains(where: { $0.id == idUser }) {
            router?.showAlertWithTitle(DetailPresenterConstants.alreadyParticipating)
            return
        }
        
        network?.writeUserToEvent(idEvent: idEvent, idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                
                
                let hours = Calendar.current.component(.hour, from: date)
                notification.createNotification(
                    identifier: idEvent,
                    title: DetailPresenterConstants.matchReminder,
                    body: "\(DetailPresenterConstants.eventTomorrowAt) \(hours)",
                    date: date
                )
                
                if isComplete {
                    router?.showAlertWithTitle(DetailPresenterConstants.queueAdded)
                } else {
                    router?.showAlertWithTitle(DetailPresenterConstants.userAdded)
                }
            case .failure(let error):
                router?.showAlertWithTitle(DetailPresenterConstants.saveError)
                view?.error(error: error.localizedDescription)
            }
        })
    }
    
    //MARK: - Remove user
    func removeUserFromEvent(idEvent: String) {
        guard idEvent != "" else {
            router?.showAlertWithTitle(DetailPresenterConstants.selectEvent)
            return
        }
        
//        guard let idUser = firebase.currentUser?.uid else {
        guard let idUser = firebase.currentUserId else {
            router?.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }
        
        guard let users = users, users.contains(where: { $0.id == idUser }) else {
            router?.showAlertWithTitle(DetailPresenterConstants.notParticipating)
            return
        }
        
        network?.removeUserFromEvent(idEvent: idEvent, idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                router?.showAlertWithTitle(DetailPresenterConstants.unsubscribed)
                notification.cancelNotification(identifier: idEvent)
            case .failure(let error):
                router?.showAlertWithTitle(DetailPresenterConstants.deleteError)
                view?.error(error: error.localizedDescription)
            }
        })
    }

    func shareEvent(eventID: String) {
        let shareURL = "dvor://openScreen?screen=detail&eventId="
        let fullURL = shareURL + eventID
        view?.load()
        router?.showShareSheet(items: [fullURL]) { [weak self] completed in
            guard let self = self else { return }
            self.view?.hideLoading()
        }
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
