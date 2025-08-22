
protocol TabBarProtocol: AnyObject {
    func setTabbarControllers(controllers: TabBarModels)
}

protocol TabBarPresenterProtocol: AnyObject {
    init(view: TabBarProtocol, model: TabBarModels)
    func showView()
}

class TabBarPresenter: TabBarPresenterProtocol {
    weak var view: TabBarProtocol?
    var model: TabBarModels
    
    required init(view: TabBarProtocol, model: TabBarModels) {
        self.view = view
        self.model = model
    }
    
    func showView() {
        self.view?.setTabbarControllers(controllers: model)
    }
}
