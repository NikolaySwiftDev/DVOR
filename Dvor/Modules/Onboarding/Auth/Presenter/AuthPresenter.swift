
import Foundation


//protocol AuthPresenterProtocol: AnyObject {
//    init(router: RouterMainProtocol, firebase: FirebaseAuthManagerProtocol, coordinator: AppCoordinatorProtocol)
//    
//    func signIn(email: String, password: String)
//    func popVC()
//}
//
//final class AuthPresenter: AuthPresenterProtocol {
//
//    private weak var coordinator: AppCoordinatorProtocol?
//    let router: RouterMainProtocol
//    let firebase: FirebaseAuthManagerProtocol
//    
//    
//    init(router: RouterMainProtocol, firebase: FirebaseAuthManagerProtocol, coordinator: AppCoordinatorProtocol) {
//        self.router = router
//        self.firebase = firebase
//        self.coordinator = coordinator
//    }
//
//    func signIn(email: String, password: String) {
//        firebase.signIn(email: email, password: password) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(_):
//                coordinator?.showHome()
//            case .failure(let failure):
//                router.showAlertWithTitle(failure.localizedDescription)
//            }
//        }
//    }
//    
//    func popVC() {
//        router.popVC()
//    }
//
//    deinit {
//        print("AuthPresenterProtocol deinit")
//    }
//}
