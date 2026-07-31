import Foundation

protocol DetailProtocol: AnyObject {
    func success(users: [UserModel], org: OrganizatorModel)
    func load()
    func updateUsers(model: [String])
    func error(error: String)
    func hideLoading()
    func successComments(comments: [CommentModel])
}

protocol DetailPresenterProtocol: AnyObject {
    init(view: DetailProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol,
         notification: NotificationManagerProtocol,
         comments: FirebaseCommentsManagerProtocol
    )
    
    var users: [UserModel]? { get set }
    var org: OrganizatorModel? { get set }
    var comments: [CommentModel]? { get set }
    
    func fetchAllUsers(usersID: [String], orgID: String)
    func addUserToEvent(idEvent: String, date: Date, time: String, isComplete: Bool, city: CityModel)
    func removeUserFromEvent(idEvent: String)
    
    func fetchComments(idEvent: String)
    func addComment(idEvent: String, text: String)
    func removeComment(idEvent: String, commentId: String)
    
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
    var comments: [CommentModel]?
    let router: RouterMainProtocol
    let network: FirebaseDataManagerProtocol
    let firebase: FirebaseAuthManagerProtocol
    let notification: NotificationManagerProtocol
    let commentsManager: FirebaseCommentsManagerProtocol

    required init(view: DetailProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol,
                  firebase: FirebaseAuthManagerProtocol,
                  notification: NotificationManagerProtocol,
                  comments: FirebaseCommentsManagerProtocol
    ) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
        self.notification = notification
        self.commentsManager = comments
    }
    
    //MARK: - Fetch all users
    func fetchAllUsers(usersID: [String], orgID: String) {
        view?.load()
        network.fetchAllUsersFromEvent(usersID: usersID, orgId: orgID, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let users, let org)):
                self.users = users
                self.org = org
                view?.success(users: users, org: org ?? OrganizatorModel())
            case .failure(let failure):
                view?.error(error: failure.localizedDescription)
                router.showAlertWithTitle(failure.localizedDescription)
            }
        })
    }
    
    //MARK: - Add user
    func addUserToEvent(idEvent: String, date: Date, time: String, isComplete: Bool, city: CityModel) {
        guard idEvent != "" else {
            router.showAlertWithTitle(DetailPresenterConstants.selectEvent)
            return
        }

        guard let idUser = firebase.currentUserId, let currentCity = firebase.currentCity else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }

        guard currentCity == city else {
            router.showAlertWithTitle(DetailPresenterConstants.differentCity)
            return
        }

        if let users = users, users.contains(where: { $0.id == idUser }) {
            router.showAlertWithTitle(DetailPresenterConstants.alreadyParticipating)
            return
        }

        network.hasEventOnSameDay(userId: idUser, date: date, excludingEventId: idEvent) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let hasConflict):
                guard !hasConflict else {
                    self.router.showAlertWithTitle(DetailPresenterConstants.alreadyHasEventThisDay)
                    return
                }
                self.proceedWithJoining(idEvent: idEvent, idUser: idUser, date: date, time: time, isComplete: isComplete)
            case .failure(let error):
                self.router.showAlertWithTitle(error.localizedDescription)
            }
        }
    }

    private func proceedWithJoining(idEvent: String, idUser: String, date: Date, time: String, isComplete: Bool) {
        network.writeUserToEvent(idEvent: idEvent, idUser: idUser) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                notification.createNotification(
                    identifier: idEvent,
                    title: DetailPresenterConstants.matchReminder,
                    body: "\(DetailPresenterConstants.eventTomorrowAt) \(" ") \(time)",
                    date: date
                )
                router.showAlertWithTitle(
                    isComplete ? DetailPresenterConstants.queueAdded : DetailPresenterConstants.userAdded
                )
            case .failure:
                router.showAlertWithTitle(DetailPresenterConstants.saveError)
            }
        }
    }
    
    //MARK: - Remove user
    func removeUserFromEvent(idEvent: String) {
        guard idEvent != "" else {
            router.showAlertWithTitle(DetailPresenterConstants.selectEvent)
            return
        }
        
        guard let idUser = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }
        
        guard let users = users, users.contains(where: { $0.id == idUser }) else {
            router.showAlertWithTitle(DetailPresenterConstants.notParticipating)
            return
        }
        
        network.removeUserFromEvent(idEvent: idEvent, idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                view?.updateUsers(model: success)
                router.showAlertWithTitle(DetailPresenterConstants.unsubscribed)
                notification.cancelNotification(identifier: idEvent)
            case .failure(let error):
                router.showAlertWithTitle(DetailPresenterConstants.deleteError)
                view?.error(error: error.localizedDescription)
            }
        })
    }

    //MARK: - Fetch comments
    func fetchComments(idEvent: String) {
        view?.load()
        commentsManager.fetchComments(idEvent: idEvent) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideLoading()
            switch result {
            case .success(let comments):
                self.comments = comments
                self.view?.successComments(comments: comments)
            case .failure(let error):
                self.view?.error(error: error.localizedDescription)
            }
        }
    }

    //MARK: - Add comment
    func addComment(idEvent: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let idUser = firebase.currentUserId else {
            router.showAlertWithTitle(DetailPresenterConstants.addAccount)
            return
        }

        network.fetchUser(idUser: idUser) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let newComment = CommentModel(
                    id: "",
                    userId: idUser,
                    userName: user.name,
                    userImage: user.image,
                    text: trimmed,
                    date: Date()
                )
                self.commentsManager.addComment(idEvent: idEvent, comment: newComment) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let comment):
                        var updated = self.comments ?? []
                        updated.append(comment)
                        self.comments = updated
                        self.view?.successComments(comments: updated)
                    case .failure(let error):
                        self.view?.error(error: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.view?.error(error: error.localizedDescription)
            }
        }
    }

    //MARK: - Remove comment
    func removeComment(idEvent: String, commentId: String) {
        commentsManager.deleteComment(idEvent: idEvent, commentId: commentId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let updated = (self.comments ?? []).filter { $0.id != commentId }
                self.comments = updated
                self.view?.successComments(comments: updated)
            case .failure(let error):
                self.view?.error(error: error.localizedDescription)
            }
        }
    }

    func shareEvent(eventID: String) {
        let shareURL = "dvor://openScreen?screen=detail&eventId="
        let fullURL = shareURL + eventID
        view?.load()
        router.showShareSheet(items: [fullURL]) { [weak self] completed in
            guard let self = self else { return }
            self.view?.hideLoading()
        }
    }
    
    func showBottomAlertForUser(model: UserModel) {
        router.showBottomSheetAlertForUser(model: model)
    }
    
    func showLocationOnMap(location: String) {
        router.showLocationOnMap(location: location)
    }
    
    func showDetailOrgInfo(model: OrganizatorModel) {
        router.pushDetailOrgInfo(model: model)
    }
    
    func popVC() {
        router.popVC()
    }
    
    deinit {
         print("Deinit Detail Presenter")
    }
}
