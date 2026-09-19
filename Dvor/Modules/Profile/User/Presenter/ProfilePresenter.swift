
import Foundation

protocol ProfileProtocol: AnyObject {
    func success(model: UserModel)
    func error(error: Error)
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
    
    func deleteProfile() {
        router.showAlertConfigur(title: ProfileViewConstants.alerttitledelete,
                                 message: ProfileViewConstants.alertdesc,
                                 titleActionButton: "Yes".loc,
                                 handelr: { [weak self] in
            guard let self = self else { return }
            firebase.signOut(completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
//                    guard let id = self.user?.id else { return }
//                    self.network.removeUser(userID: id, completion: { [weak self] result in
//                        guard let self = self else { return }
//                        switch result {
//                        case .success():
                            storage?.clearCity()
                            notification.cancelAllNotifications()
                            self.appCoordinator?.showRegistration()
//                        case .failure(let error):
//                            self.router.showAlertWithTitle(error.localizedDescription)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                self.router.popVC()
//                            }
//                        }
//                    })
                case .failure(let error):
                    self.router.showAlertWithTitle(error.errorDescription ?? "auth_error_unknown".loc)
                }
            })
        })
    }
    
    func popVC() {
        router.popVC()
    }
    
    deinit {
        print(#function, self)
    }
}
