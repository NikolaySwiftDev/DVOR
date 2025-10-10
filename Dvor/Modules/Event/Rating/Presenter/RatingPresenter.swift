protocol RatingProtocol: AnyObject {}

protocol RatingPresenterProtocol: AnyObject {
    init(view: RatingProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol)
    func popVC()
    func saveRating(rate: Int)
}

final class RatingPresenter: RatingPresenterProtocol {
    weak var view: RatingProtocol?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    
    required init(view: RatingProtocol, router: RouterMainProtocol, network: FirebaseDataManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
    }
    
    func popVC() {
        router?.popVC()
    }
    
    func saveRating(rate: Int) {
        network?.updateUserFollowers()
    }
    
    deinit {
        print("deinit RatingPresenterProtocol")

    }
}

