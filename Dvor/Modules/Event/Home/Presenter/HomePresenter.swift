import Foundation

protocol HomeProtocol: AnyObject {
    func success()
    func error(error: Error)
}

protocol HomePresenterProtocol: AnyObject {
    var events: [EventModel]? { get set }
    var filteredEvents: [EventModel]? { get set }
    
    func fetchEvents()
    func writeEvent(model: EventModel)
    func filterEventsWithDate(date: Date)
    func addUserToEvent(idEvent: String)
    func deleteEvent(eventId: String)
    
    func showLocationOnMap(location: String)
    func pushDetailVC(model: EventModel)
    
    init(view: HomeProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         userDefaults: UserDefaultsProtocol
    )
}

final class HomePresenter: HomePresenterProtocol {

    weak var view: HomeProtocol?
    var events: [EventModel]?
    var filteredEvents: [EventModel]?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let userDefaults: UserDefaultsProtocol?
    
    private var lastFilterDate: Date = .now

    required init(view: HomeProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol,
                  userDefaults: UserDefaultsProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.userDefaults = userDefaults
        setupRealTimeObservation()
    }

    
    //MARK: - Настройка наблюдения в реальном времени
    private func setupRealTimeObservation() {
        network?.startObservingEvents(completion: { [weak self] result in
            guard let self = self else { return }
            self.handleEventsResult(result)
        })
    }
    
    //MARK: - Остановка наблюдения
    private func stopRealTimeObservation() {
        network?.stopObservingEvents()
    }
    
    //MARK: - Общая обработка результатов
    private func handleEventsResult(_ result: Result<[EventModel], Error>) {
        switch result {
        case .success(let events):
            self.events = events
            self.filterEventsWithDate(date: lastFilterDate)
            self.view?.success()
        case .failure(let error):
            self.view?.error(error: error)
        }
    }
    
    //MARK: - Общий метод отправки запроса и наблюдение за БД
    func fetchEvents() {
        network?.fetchEvents(completion: { [weak self] result in
            guard let self = self else { return }
            self.handleEventsResult(result)
        })
    }
    
    //MARK: - Записсь события в БД
    func writeEvent(model: EventModel) {
        network?.writeEvents(model: model, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                router?.showErrorAlerWithTitle(success)
            case .failure(let error):
                router?.showErrorAlerWithTitle("Ошибка сохранения")
                view?.error(error: error)
            }
        })
    }
    
    //MARK: - фильтрация Событий
    func filterEventsWithDate(date: Date) {
        guard let events = events else { return }
        let calendar = Calendar.current
        filteredEvents = events.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
        lastFilterDate = date
        view?.success()
    }
    
    //MARK: - Добавление участника
    func addUserToEvent(idEvent: String) {
        guard idEvent != "" else {
            router?.showErrorAlerWithTitle("Выберите событие")
            return
        }
        
        guard let idUser = userDefaults?.getIDUser() else {
            router?.showErrorAlerWithTitle("Добавьте аккаунт")
            return
        }
                
        network?.addUserToEvent(idEvent: idEvent, idUser: idUser, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                router?.showErrorAlerWithTitle(success)
            case .failure(let error):
                router?.showErrorAlerWithTitle("Ошибка сохранения")
                view?.error(error: error)
            }
        })
    }

    //MARK: - Удаление собитыя
    func deleteEvent(eventId: String) {
        guard eventId != "" else {
            router?.showErrorAlerWithTitle("Выберите событие")
            return
        }
        network?.deleteEvent(idEvent: eventId, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let success):
                router?.showErrorAlerWithTitle(success)
            case .failure(let error):
                router?.showErrorAlerWithTitle("Ошибка удаления")
                view?.error(error: error)
            }
        })
    }
    
    //MARK: - Отображение на карте
    func showLocationOnMap(location: String) {
        router?.showLocationOnMap(location: location)
    }
    
    //MARK: - Пуш в детальный экран
    func pushDetailVC(model: EventModel) {
        let details = model.toDetailModel()
        router?.pushDetailVC(model: details)
    }
    
    //MARK: - Deinit
    deinit {
        print("Deinit HomePresenter")
        stopRealTimeObservation()
    }
}
