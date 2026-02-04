import Foundation

// MARK: - View Protocol
protocol CreateEventProtocol: AnyObject {
    func success()
    func error(error: Error)
}

// MARK: - Presenter Protocol
protocol CreateEventPresenterProtocol: AnyObject {
    var view: CreateEventProtocol? { get }
    var router: RouterMainProtocol? { get }
    
    init(view: CreateEventProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol)

    func writeEvent(players: Int, date: Date, time: String, address: String)
    func popVC()

}

// MARK: - Presenter Implementation
final class CreateEventPresenter: CreateEventPresenterProtocol {
    
    // MARK: - Properties
    weak var view: CreateEventProtocol?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let firebase: FirebaseAuthManagerProtocol
    
    // MARK: - Initializers
    init(view: CreateEventProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
    }
    
    // MARK: - Methods
    func popVC() {
        router?.popVC()
    }
    
    //MARK: - Записсь события в БД
    func writeEvent(players: Int, date: Date, time: String, address: String) {
        guard let orgID = firebase.currentUser?.uid else {
            router?.showAlertWithTitle("Зарегистрируйтесь")
            return
        }
        let model = EventModel(date: date,
                               time: time,
                               name: "",
                               format: players,
                               location: "",
                               address: address,
                               namePlace: "",
                               price: 0,
                               ownerName: "",
                               timeGame: 0,
                               orgId: orgID)
        
        network?.writeEvents(model: model, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                router?.showAlertConfigur(title: success, message: nil, titleActionButton: "Вернуться") { [weak self] in
                    guard let self = self else { return }
                    self.router?.popVC()
                }
            case .failure(let error):
                router?.showAlertWithTitle("Ошибка сохранения")
                view?.error(error: error)
            }
        })
    }
    
    deinit {
        print("CreateEventPresenter deinitialized")
    }
}
