
import Foundation

protocol ProfileProtocol: AnyObject {
    func success(model: UserModel)
    func error(error: Error)
    func setDeleteInProgress(_ inProgress: Bool)
}

protocol ProfilePresenterProtocol: AnyObject {
    var user: UserModel? { get set }
    init(view: ProfileProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol,
         notification: NotificationManagerProtocol,
         appCoordinator: AppCoordinatorProtocol?,
         storage: CityStorageProtocol?
    )
    
    func getProfileInto()
    func editProfile()
    func deleteProfile()
    func signOut()
    func confirmDeleteProfile(password: String)
    func popVC()
}

final class ProfilePresenter: ProfilePresenterProtocol {

    var user: UserModel?

    weak var view: ProfileProtocol?
    let router: RouterMainProtocol
    let network: FirebaseDataManagerProtocol
    let firebase: FirebaseAuthManagerProtocol
    let notification: NotificationManagerProtocol
    let appCoordinator: AppCoordinatorProtocol?
    let storage: CityStorageProtocol?
    
    init(view: ProfileProtocol,
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
    
    func getProfileInto() {
        guard let idUser = firebase.currentUserId else {
            router.showAlertWithTitle("detail.add_account".loc)
            return
        }
        
        network.fetchUser(idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                self.user = success
                view?.success(model: success)
            case .failure(let failure):
                view?.error(error: failure)
                router.showAlertWithTitle(failure.localizedDescription)
            }
        })
    }
    
    func editProfile() {
        guard let model = user else {
            router.showAlertWithTitle("auth.no_user".loc)
            return
        }
        
        router.showEditAlert(model: model)
    }
    
    //MARK: - Sign out (the old behaviour of the button)
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
    func deleteProfile() {
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
            self?.confirmDeleteProfile(password: password)
        })
    }

    private func finishSession() {
        storage?.clearCity()
        notification.cancelAllNotifications()
        appCoordinator?.showRegistration()
    }
    
    func confirmDeleteProfile(password: String) {
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
    
    func popVC() {
        router.popVC()
    }
    
    deinit {
        print(#function, self)
    }
}
