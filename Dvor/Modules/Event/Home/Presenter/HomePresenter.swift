import Foundation

protocol HomeProtocol: AnyObject {
    func success()
    func error(error: Error)
}

protocol HomePresenterProtocol: AnyObject {
    var events: [EventModel]? { get set }
    var filteredEvents: [EventModel]? { get set }
    func fetchEvents()
    func filterEventsWithDate(date: Date)
    func showLocationOnMap(location: String)
    func pushDetailVC(model: EventModel)
    init(view: HomeProtocol, router: RouterMainProtocol, network: NetworkServiceProtocol)
}

final class HomePresenter: HomePresenterProtocol {

    weak var view: HomeProtocol?
    var events: [EventModel]?
    var filteredEvents: [EventModel]?
    let router: RouterMainProtocol?
    let network: NetworkServiceProtocol?

    required init(view: HomeProtocol, router: RouterMainProtocol, network: NetworkServiceProtocol) {
        self.view = view
        self.router = router
        self.network = network
    }
    
    func fetchEvents() {
        network?.fetchEvents(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                events = success
                view?.success()
            case .failure(let failure):
                view?.error(error: failure)
            }
        })
    }
    
    func filterEventsWithDate(date: Date) {
        guard let events = events else { return }
        let calendar = Calendar.current
        filteredEvents = events.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
        view?.success()
    }
    
    func showLocationOnMap(location: String) {
        router?.showLocationOnMap(location: location)
    }
    
    func pushDetailVC(model: EventModel) {
        router?.pushDetailVC(model: model)
    }
}
