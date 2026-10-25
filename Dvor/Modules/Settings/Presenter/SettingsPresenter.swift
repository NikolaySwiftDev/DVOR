import Foundation

protocol SettingsProtocol: AnyObject {
    func setDeleteInProgress(_ inProgress: Bool)
}

protocol SettingsPresenterProtocol: AnyObject {
    init(view: SettingsProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol,
         notification: NotificationManagerProtocol,
         appCoordinator: AppCoordinatorProtocol?,
         storage: CityStorageProtocol?
    )

    func showBlockedUsers()
    func openPrivacy()
    func openTerms()
    func signOut()
    func deleteAccount()
    func confirmDeleteAccount(password: String)
    func popVC()
}

final class SettingsPresenter: SettingsPresenterProtocol {

    private weak var view: SettingsProtocol?
    private let router: RouterMainProtocol
    private let network: FirebaseDataManagerProtocol
    private let firebase: FirebaseAuthManagerProtocol
    private let notification: NotificationManagerProtocol
    private weak var appCoordinator: AppCoordinatorProtocol?
    private let storage: CityStorageProtocol?

    required init(view: SettingsProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol,
                  firebase: FirebaseAuthManagerProtocol,
                  notification: NotificationManagerProtocol,
                  appCoordinator: AppCoordinatorProtocol?,
                  storage: CityStorageProtocol?
    ) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
        self.notification = notification
        self.appCoordinator = appCoordinator
        self.storage = storage
    }

    //MARK: - Navigation
    func showBlockedUsers() {
        router.pushBlockedUsersVC()
    }

    func openPrivacy() {
        router.openLink(AppLinks.privacy)
    }

    func openTerms() {
        router.openLink(AppLinks.terms)
    }

    func popVC() {
        router.popVC()
    }

    //MARK: - Sign out
    func signOut() {
        router.showAlertConfigur(title: ProfileViewConstants.alerttitledelete,
                                 message: ProfileViewConstants.alertdesc,
                                 titleActionButton: "Yes".loc,
                                 handelr: { [weak self] in
            guard let self = self else { return }

            self.firebase.signOut(completion: { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.finishSession()
                case .failure(let error):
                    self.router.showAlertWithTitle(error.errorDescription ?? "auth_error_unknown".loc)
                }
            })
        })
    }

    //MARK: - Delete account (confirmation, then the password prompt)
    func deleteAccount() {
        router.showAlertConfigur(title: ProfileViewConstants.deleteAccountAlertTitle,
                                 message: ProfileViewConstants.deleteAccountAlertMessage,
                                 titleActionButton: "Yes".loc,
                                 handelr: { [weak self] in
            self?.askPasswordToDelete()
        })
    }

    private func askPasswordToDelete() {
        router.showPasswordPrompt(title: ProfileViewConstants.passwordTitle,
                                  message: ProfileViewConstants.passwordMessage,
                                  placeholder: ProfileViewConstants.passwordPlaceholder,
                                  confirmTitle: ProfileViewConstants.deleteButton,
                                  onConfirm: { [weak self] password in
            self?.confirmDeleteAccount(password: password)
        })
    }

    func confirmDeleteAccount(password: String) {
        guard let userID = firebase.currentUserId else {
            router.showAlertWithTitle("detail.add_account".loc)
            return
        }

        view?.setDeleteInProgress(true)

        // 1. Check the password
        firebase.reauthenticate(password: password) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.failDeletion(error.errorDescription ?? "auth_error_unknown".loc)

            case .success:
                // 2. Delete the data (profile, participation, own events)
                self.network.removeUser(userID: userID) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .failure(let error):
                        self.failDeletion(error.localizedDescription)

                    case .success:
                        // 3. Delete the Firebase Auth account
                        self.firebase.deleteAccount { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success:
                                self.finishSession()
                            case .failure(let error):
                                self.failDeletion(error.errorDescription ?? "auth_error_unknown".loc)
                            }
                        }
                    }
                }
            }
        }
    }

    private func failDeletion(_ message: String) {
        view?.setDeleteInProgress(false)
        router.showAlertWithTitle(message)
    }

    private func finishSession() {
        storage?.clearCity()
        notification.cancelAllNotifications()
        appCoordinator?.showRegistration()
    }
    
    deinit {
        print(#function, self)
    }
}
