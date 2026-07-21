import Foundation

// MARK: - View Protocol
protocol CreateEventProtocol: AnyObject {
    func success(city: String)
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

    func writeEvent(players: Int, date: Date, time: String, address: String, place: String)
    
    func getCityForSearchAdress()
    
    func popVC()
    func showInfoAlert()

}

// MARK: - Presenter Implementation
final class CreateEventPresenter: CreateEventPresenterProtocol {
    
    // MARK: - Properties
    weak var view: CreateEventProtocol?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol
    let firebaseAuth: FirebaseAuthManagerProtocol
    
    // MARK: - Initializers
    init(view: CreateEventProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.firebaseAuth = firebase
    }
    
    private var city: CityModel?
    
    // MARK: - Methods
    func popVC() {
        router?.popVC()
    }
    
    //MARK: -
    
    func getCityForSearchAdress() {
        guard firebaseAuth.currentUserId != nil else {
            router?.showAlertWithTitle(CreateEventPresenterStrings.signUp)
            return
        }
        
        guard let city = firebaseAuth.currentCity else { return }
        self.city = city
        view?.success(city: city.name)
        
//        network.fetchUser(idUser: orgID) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let success):
//                let city = CityModel(name: success.city, countryCode: success.countryCode, administrativeArea: success.administrativeArea, latitude: success.latitude ?? 0, longitude: success.longitude ?? 0)
//                self.city = city
//                print(city.countryCode)
//                view?.success(city: city.name)
//            case .failure(let failure):
//                print(failure.localizedDescription)
//            }
//        }
        
    }
    
    //MARK: - Record events in the database
    func writeEvent(players: Int, date: Date, time: String, address: String, place: String) {
//        guard let orgID = firebase.currentUser?.uid else {
        guard let orgID = firebaseAuth.currentUserId else {
            router?.showAlertWithTitle(CreateEventPresenterStrings.signUp)
            return
        }
        let model = EventModel(date: date,
                               time: time,
                               name: "",
                               format: players,
                               city: city?.name ?? "Emtpy",
                               countryCode: city?.countryCode ?? "",
                               administrativeArea: city?.administrativeArea ?? "",
                               latitude: city?.latitude ?? 0,
                               longitude: city?.longitude ?? 0,
                               address: address,
                               namePlace: place,
                               price: 0,
                               ownerName: "",
                               timeGame: 0,
                               orgId: orgID)
        
        network.writeEvents(model: model, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.router?.popVC()
            case .failure(let error):
                router?.showAlertWithTitle(CreateEventPresenterStrings.saveError)
                view?.error(error: error)
            }
        })
    }
    
    func showInfoAlert() {
        router?.showAlertWithTitle(CreateEventPresenterStrings.infoAlert)
    }
    
    deinit {
        print("CreateEventPresenter deinitialized")
    }
}

fileprivate struct CreateEventPresenterStrings {
    static let signUp = "create_event.sign_up".loc
    static let saveError = "common.save_error".loc
    static let infoAlert = "create_event.info_alert".loc
}
