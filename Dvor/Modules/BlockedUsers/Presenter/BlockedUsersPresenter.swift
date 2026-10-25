import Foundation

protocol BlockedUsersProtocol: AnyObject {
    func show(users: [UserModel])
    func setLoading(_ isLoading: Bool)
}

protocol BlockedUsersPresenterProtocol: AnyObject {
    init(view: BlockedUsersProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol,
         moderation: ModerationManagerProtocol)

    func fetchBlockedUsers()
    func unblock(user: UserModel)
    func popVC()
}

final class BlockedUsersPresenter: BlockedUsersPresenterProtocol {

    private weak var view: BlockedUsersProtocol?
    private let router: RouterMainProtocol
    private let network: FirebaseDataManagerProtocol
    private let firebase: FirebaseAuthManagerProtocol
    private let moderation: ModerationManagerProtocol
    private var users: [UserModel] = []

    required init(view: BlockedUsersProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol,
                  firebase: FirebaseAuthManagerProtocol,
                  moderation: ModerationManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
        self.moderation = moderation
    }

    //MARK: - Load the list
    func fetchBlockedUsers() {
        guard let myID = firebase.currentUserId else {
            view?.show(users: [])
            return
        }

        view?.setLoading(true)

        moderation.fetchBlockedUserIDs(userId: myID) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let ids):
                self.loadUsers(ids: Array(ids))
            case .failure(let error):
                self.view?.setLoading(false)
                self.router.showAlertWithTitle(error.localizedDescription)
            }
        }
    }

    private func loadUsers(ids: [String]) {
        guard !ids.isEmpty else {
            users = []
            view?.setLoading(false)
            view?.show(users: [])
            return
        }

        var loaded: [UserModel] = []
        let lock = NSLock()
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            network.fetchUser(idUser: id) { result in
                // a deleted account can no longer be loaded: it is simply skipped
                if case .success(let user) = result {
                    lock.lock()
                    loaded.append(user)
                    lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.users = loaded.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            self.view?.setLoading(false)
            self.view?.show(users: self.users)
        }
    }

    //MARK: - Unblock
    func unblock(user: UserModel) {
        guard let myID = firebase.currentUserId else { return }

        moderation.unblockUser(blockerId: myID, blockedId: user.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.users.removeAll { $0.id == user.id }
                self.view?.show(users: self.users)
            case .failure(let error):
                self.router.showAlertWithTitle(error.localizedDescription)
            }
        }
    }

    func popVC() {
        router.popVC()
    }
    
    deinit {
        print(#function, self)
    }
}
