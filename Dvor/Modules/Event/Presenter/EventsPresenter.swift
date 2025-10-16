import Foundation

protocol EventsProtocol: AnyObject {
    func success(date: String)
    func error(error: Error)
}

protocol EventsPresenterProtocol: AnyObject {
    var events: [EventModel]? { get set }
    var filteredEvents: [EventModel]? { get set }
    
    func fetchEvents()
    func writeEvent(model: EventModel)
    func filterEventsWithDate(date: Date)
    func sortEventsWithPredicate(predicate: SortPredicate)
    
    func deleteEvent(eventId: String)
    
    func createNewEvent() //mock
    
    func showLocationOnMap(location: String)
    func pushDetailVC(model: EventModel)
    func pushProfileVC()
    func pushCreateEvent()
    
    init(view: EventsProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         userDefaults: UserDefaultsProtocol
    )
}

final class EventsPresenter: EventsPresenterProtocol {
    weak var view: EventsProtocol?
    var events: [EventModel]?
    var filteredEvents: [EventModel]?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let userDefaults: UserDefaultsProtocol?
    
    private var lastFilterDate: Date = .now
    private var lastSortPredicate: SortPredicate = .count

    required init(view: EventsProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol,
                  userDefaults: UserDefaultsProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.userDefaults = userDefaults
//        setupRealTimeObservation()
    }

    
//    //MARK: - Настройка наблюдения в реальном времени
//    private func setupRealTimeObservation() {
//        network?.startObservingEvents(completion: { [weak self] result in
//            guard let self = self else { return }
//            self.handleEventsResult(result)
//        })
//    }
//    
//    //MARK: - Остановка наблюдения
//    private func stopRealTimeObservation() {
//        network?.stopObservingEvents()
//    }
    
    //MARK: - Общая обработка результатов
    private func handleEventsResult(_ result: Result<[EventModel], Error>) {
        switch result {
        case .success(let events):
            self.events = events
            self.filterEventsWithDate(date: lastFilterDate)
            self.sortEventsWithPredicate(predicate: lastSortPredicate)
//            view?.success(date: lastFilterDate.toString())
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
                break
//                router?.showAlertWithTitle(success)
            case .failure(let error):
                router?.showAlertWithTitle("Ошибка сохранения")
                view?.error(error: error)
            }
        })
    }
    
    //MARK: - фильтрация Событий по Дате
    func filterEventsWithDate(date: Date) {
//        fetchEvents()
        guard let events = events else { return }
        let calendar = Calendar.current
        filteredEvents = events.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
        lastFilterDate = date
        view?.success(date: lastFilterDate.toString())
    }
    
    //MARK: - фильтрация Событий по заданному параметру

    func sortEventsWithPredicate(predicate: SortPredicate) {
        switch predicate {
        case .count:
            let sortEvents = filteredEvents?.sorted { $0.peopleAllCountInt < $1.peopleAllCountInt }
            filteredEvents = sortEvents
        case .time:
            let sortEvents = filteredEvents?.sorted { $0.time < $1.time }
            filteredEvents = sortEvents
        case .address:
            let sortEvents = filteredEvents?.sorted { $0.address < $1.address }
            filteredEvents = sortEvents
        }
        view?.success(date: lastFilterDate.toString())

    }
    


    //MARK: - Удаление собитыя
    func deleteEvent(eventId: String) {
        guard eventId != "" else {
            router?.showAlertWithTitle("Выберите событие")
            return
        }
        network?.deleteEvent(idEvent: eventId, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let success):
                fetchEvents()
//                router?.showAlertWithTitle(success)
            case .failure(let error):
                router?.showAlertWithTitle("Ошибка удаления")
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

    //MARK: - Пуш в детальный экран
    func pushProfileVC() {
        router?.pushProfileVC()
    }
    
    //MARK: - Пуш в экран создания события
    func pushCreateEvent() {
        router?.pushCreateEvent()
    }

    //MARK: - Deinit
    deinit {
        print("Deinit HomePresenter")
//        stopRealTimeObservation()
    }
    
    //MOCK
    func createNewEvent() {
        guard let orgID = userDefaults?.getIDUser() else {
            router?.showAlertWithTitle("Зарегистрируйтесь")
            return
        }
        
        let model = EventModel(date: lastFilterDate,
                               time: "18:00",
                               name: "Товарка",
                               format: 11,
                               location: "Спб",
                               address: "пр. Просвещения 25",
                               namePlace: "Школа 555",
                               price: 1000,
                               ownerName: "Орг",
                               timeGame: 120,
//                               totalPeopleCount: 4,
                               orgId: orgID)
        
        let model1 = EventModel(date: lastFilterDate,
                               time: "17:00",
                               name: "Игра",
                               format: 8,
                               location: "Спб",
                               address: "пр. Энгелься 30",
                               namePlace: "Школа 555",
                               price: 1000,
                               ownerName: "Орг",
                               timeGame: 120,
//                               totalPeopleCount: 8,
                               orgId: orgID)
        
        let model2 = EventModel(date: lastFilterDate,
                               time: "12:00",
                               name: "Турнир",
                               format: 5,
                               location: "Спб",
                               address: "пр. Новаторов 112",
                               namePlace: "Школа 255",
                               price: 1000,
                               ownerName: "Орг",
                               timeGame: 120,
//                               totalPeopleCount: 8,
                               orgId: orgID)
        
        writeEvent(model: model)
        writeEvent(model: model1)
        writeEvent(model: model2)
        
        
    }
}
