protocol RatingProtocol: AnyObject {}

protocol RatingPresenterProtocol: AnyObject {
    init(view: RatingProtocol, router: RouterMainProtocol)
    func popVC()
    func saveRating(rate: Int)
}

final class RatingPresenter: RatingPresenterProtocol {
    weak var view: RatingProtocol?
    var router: RouterMainProtocol?
    
    required init(view: RatingProtocol, router: RouterMainProtocol) {
        self.view = view
        self.router = router
    }
    
    func popVC() {
        router?.popVC()
    }
    
    func saveRating(rate: Int) {
        print(rate)
    }
    
    deinit {
        print("deinit RatingPresenterProtocol")

    }
}

