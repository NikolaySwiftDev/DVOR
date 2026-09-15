
import Foundation


protocol AuthPresenterProtocol: AnyObject {
    init(router: RouterMainProtocol,
         firebase: FirebaseAuthManagerProtocol,
         network: FirebaseDataManagerProtocol,
         storage: CityStorageProtocol
    )
    
    func signIn(email: String, password: String)
    func popVC()
}

final class AuthPresenter: AuthPresenterProtocol {

    let router: RouterMainProtocol
    let firebase: FirebaseAuthManagerProtocol
    let network: FirebaseDataManagerProtocol
    let storage: CityStorageProtocol
    
    init(router: RouterMainProtocol,
         firebase: FirebaseAuthManagerProtocol,
         network: FirebaseDataManagerProtocol,
         storage: CityStorageProtocol
    ) {
        self.router = router
        self.firebase = firebase
        self.network = network
        self.storage = storage
    }

    func signIn(email: String, password: String) {
        firebase.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let uid):
                network.fetchUser(idUser: uid) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let success):
                        let city = success.toCityModel()
                        storage.updateCity(city)
                        router.pushHomeVC()
                    case .failure(let failure):
                        router.showAlertWithTitle(failure.localizedDescription)
                    }
                }
            case .failure(let failure):
                router.showAlertWithTitle(failure.localizedDescription)
            }
        }
    }
    
    func popVC() {
        router.popVC()
    }

    deinit {
//        print(#function, self)
    }
}
