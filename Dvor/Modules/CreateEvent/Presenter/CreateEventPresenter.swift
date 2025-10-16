import Foundation

// MARK: - View Protocol
protocol CreateEventProtocol: AnyObject {
    func success()
}

// MARK: - Presenter Protocol
protocol CreateEventPresenterProtocol: AnyObject {
    var view: CreateEventProtocol? { get }
    var router: RouterMainProtocol? { get }

    func popVC()
    
    init(view: CreateEventProtocol, router: RouterMainProtocol)
}

// MARK: - Presenter Implementation
final class CreateEventPresenter: CreateEventPresenterProtocol {
    
    // MARK: - Properties
    weak var view: CreateEventProtocol?
    let router: RouterMainProtocol?
    
    // MARK: - Initializers
    init(view: CreateEventProtocol, router: RouterMainProtocol) {
        self.view = view
        self.router = router
    }
    
    // MARK: - Methods
    func popVC() {
        router?.popVC()
    }
    
    deinit {
        print("CreateEventPresenter deinitialized")
    }
}
