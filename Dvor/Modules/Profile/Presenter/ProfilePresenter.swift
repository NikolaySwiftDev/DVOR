
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
         firebase: FirebaseAuthManagerProtocol)
    
    func getProfileInto()
    func popVC()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    var user: UserModel?

    weak var view: ProfileProtocol?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let firebase: FirebaseAuthManagerProtocol
    
    init(view: ProfileProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
    }
    
    func getProfileInto() {
        guard let idUser = firebase.currentUser?.uid else {
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
