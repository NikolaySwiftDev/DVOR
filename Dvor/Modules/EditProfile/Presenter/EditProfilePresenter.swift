

import Foundation

protocol EditProfileProtocol: AnyObject {
    func success()
    func error(error: Error)
}

protocol EditProfilePresenterProtocol: AnyObject {
    init(view: EditProfileProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol)
    

    func popVC()
}

final class EditProfilePresenter: EditProfilePresenterProtocol {
    
    weak var view: EditProfileProtocol?
    
    let router: RouterMainProtocol
    let network: FirebaseDataManagerProtocol

    init(view: EditProfileProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
    }

    func popVC() {
        router.popVC()
    }
}
