import Foundation

protocol EventsMapProtocol: AnyObject {}

protocol EventsMapPresenterProtocol: AnyObject {
    var events: [EventModel] { get }

    func pushDetailVC(model: EventModel)
    func popVC()

    init(view: EventsMapProtocol, router: RouterMainProtocol, events: [EventModel])
}

final class EventsMapPresenter: EventsMapPresenterProtocol {

    weak var view: EventsMapProtocol?
    let router: RouterMainProtocol
    let events: [EventModel]

    required init(view: EventsMapProtocol, router: RouterMainProtocol, events: [EventModel]) {
        self.view = view
        self.router = router
        self.events = events
    }

    func pushDetailVC(model: EventModel) {
        router.pushDetailVC(model: model.toDetailModel())
    }

    func popVC() {
        router.popVC()
    }

    deinit {
         print(#function, self)
    }
}
