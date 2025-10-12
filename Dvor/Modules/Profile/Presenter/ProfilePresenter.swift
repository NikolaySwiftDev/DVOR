
import Foundation

protocol ProfileProtocol: AnyObject {
    func success(model: UserModel)
    func error(error: Error)
}

protocol ProfilePresenterProtocol: AnyObject {
    var user: UserModel? { get set }
    init(view: ProfileProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol, userDefaults: UserDefaultsProtocol)
    
    func getProfileInto()
    func popVC()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    var user: UserModel?

    weak var view: ProfileProtocol?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let userDefaults: UserDefaultsProtocol?
    
    init(view: ProfileProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol, userDefaults: UserDefaultsProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.userDefaults = userDefaults
    }
    
    func getProfileInto() {
        guard let idUser = userDefaults?.getIDUser() else {
            router?.showAlertWithTitle("Добавьте аккаунт")
            return
        }
        
        network?.fetchUser(idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                self.user = success
                view?.success(model: success)
            case .failure(let failure):
                view?.error(error: failure)
                router?.showAlertWithTitle(failure.localizedDescription)
            }
        })
    }
    
    func popVC() {
        router?.popVC()
    }
}
