
import Foundation

protocol ProfileProtocol: AnyObject {
    func success(model: UserModel)
    func error(error: Error)
}

protocol ProfilePresenterProtocol: AnyObject {
    var user: UserModel? { get set }
    init(view: ProfileProtocol, router: RouterMainProtocol, userDefaults: UserDefaultsProtocol)
    
    func getProfileInto()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    var user: UserModel?

    weak var view: ProfileProtocol?
    var router: RouterMainProtocol
    var userDefaults: UserDefaultsProtocol
    
    init(view: ProfileProtocol, router: RouterMainProtocol, userDefaults: UserDefaultsProtocol) {
        self.view = view
        self.router = router
        self.userDefaults = userDefaults
    }
    
    func getProfileInto() {
        userDefaults.loadUserInfo(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.user = user
                view?.success(model: user)
            case .failure(let failure):
                view?.error(error: failure)
            }
        })
    }
}
