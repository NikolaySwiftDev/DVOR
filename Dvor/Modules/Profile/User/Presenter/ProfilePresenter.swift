
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
         storage: CityStorageProtocol?
    )
    
    func getProfileInto()
    func editProfile()
    func openSettings()

    func popVC()
}

final class ProfilePresenter: ProfilePresenterProtocol {

    var user: UserModel?

    weak var view: ProfileProtocol?
    private let router: RouterMainProtocol
    private let network: FirebaseDataManagerProtocol
    private let firebase: FirebaseAuthManagerProtocol
    private let notification: NotificationManagerProtocol
    private let storage: CityStorageProtocol?
    
    init(view: ProfileProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol,
         notification: NotificationManagerProtocol,
         storage: CityStorageProtocol?
    ) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
        self.notification = notification
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
    
    func openSettings() {
        router.pushSettingsVC()
    }
    
    func popVC() {
        router.popVC()
    }
    
    deinit {
        print(#function, self)
    }
}
