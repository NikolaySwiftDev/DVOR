
import Foundation


protocol AuthPresenterProtocol: AnyObject {
    init(router: RouterMainProtocol, firebase: FirebaseAuthManagerProtocol)
    
    func signIn(email: String, password: String)
    func popVC()
}

final class AuthPresenter: AuthPresenterProtocol {

    let router: RouterMainProtocol
    let firebase: FirebaseAuthManagerProtocol
    
    init(router: RouterMainProtocol, firebase: FirebaseAuthManagerProtocol) {
        self.router = router
        self.firebase = firebase
    }

    func signIn(email: String, password: String) {
        firebase.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                router.pushHomeVC()
            case .failure(let failure):
                router.showAlertWithTitle(failure.localizedDescription)
            }
        }
    }
    
    func popVC() {
        router.popVC()
    }

    deinit {
        print("AuthPresenterProtocol deinit")
    }
}
