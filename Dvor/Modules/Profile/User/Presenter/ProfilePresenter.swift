
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
            router.showAlertWithTitle("User is empty")
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
            firebase.signOut(completion: { [weak self] in
                guard let self = self, let id = user?.id else {return}
                network.removeUser(userID: id, completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success():
//                        coordinator?.showOnboarding()
                        router.pushVC(EventsViewController()) //fix
                    case .failure(let error):
                        router.showAlertWithTitle(error.localizedDescription)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.router.popVC()
                        }
                    }
                })
            })
        })
    }
    
    func popVC() {
        router.popVC()
    }
}
