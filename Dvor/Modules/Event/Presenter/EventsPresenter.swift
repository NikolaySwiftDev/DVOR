import Foundation

protocol EventsProtocol: AnyObject {
    func success(date: String)
    func error(error: Error)
    func updateAvatars(_ avatars: [String: Data])
}

protocol EventsPresenterProtocol: AnyObject {
    var events: [EventModel]? { get set }
    var userAvatars: [String: Data] { get }
    var filteredEvents: [EventModel]? { get set }
        
    func fetchEvents()
    func filterEventsWithDate(date: Date)
    func sortEventsWithPredicate(predicate: SortPredicate)
    func deleteEvent(eventId: String)
    
    func showLocationOnMap(location: String)
    func pushDetailVC(model: EventModel)
    func pushProfileVC()
    func pushCreateEvent()
    
    func signOut()
    
    init(view: EventsProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol)
}

final class EventsPresenter: EventsPresenterProtocol {

    weak var view: EventsProtocol?
    var events: [EventModel]?
    var filteredEvents: [EventModel]?
    let router: RouterMainProtocol?
    let network: FirebaseDataManagerProtocol?
    let firebase: FirebaseAuthManagerProtocol
    
    private(set) var userAvatars: [String: Data] = [:]
    private var lastFilterDate: Date = .now
    private var lastSortPredicate: SortPredicate = .count
    private var personlaMode = false

    private var title: String {
        if personlaMode {
            "Ваши события на " + lastFilterDate.toString()
        } else {
            lastFilterDate.toString()
        }
    }

    required init(view: EventsProtocol,
                  router: RouterMainProtocol,
                  network: FirebaseDataManagerProtocol,
                  firebase: FirebaseAuthManagerProtocol) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
    }
    
    //MARK: - Общая обработка результатов
    private func handleEventsResult(_ result: Result<[EventModel], Error>) {
        switch result {
        case .success(let events):
            self.events = events
            self.filterEventsWithDate(date: lastFilterDate)
            self.sortEventsWithPredicate(predicate: personlaMode ? .personal : lastSortPredicate)
            self.fetchAvatarsForEvents(events)
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
    
    private func fetchAvatarsForEvents(_ events: [EventModel]) {
        // Все уникальные ID участников по всем событиям
        let allUserIDs = Set(events.flatMap { $0.users })
        
        // Пропускаем тех, кого уже загрузили (кэш)
        let idsToFetch = allUserIDs.filter { userAvatars[$0] == nil }
        guard !idsToFetch.isEmpty else { return }
        
        let group = DispatchGroup()
        
        for userID in idsToFetch {
            group.enter()
            network?.fetchUser(idUser: userID) { [weak self] result in
                defer { group.leave() }
                guard let self = self else { return }
                
                if case .success(let user) = result, let data = user.image {
                    self.userAvatars[userID] = data  // просто Data, без UIImage
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.view?.updateAvatars(self.userAvatars)
        }
    }
    
    //MARK: - фильтрация Событий по Дате
    func filterEventsWithDate(date: Date) {
        guard let events = events else { return }
        if personlaMode {
            let calendar = Calendar.current
            filteredEvents = events.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            
//            guard let myID = firebase.currentUser?.uid else { return }
            guard let myID = firebase.currentUserId else { return }
            filteredEvents = filteredEvents?.filter { $0.users.contains(myID) }
            lastFilterDate = date
            view?.success(date: title)
        } else {
            let calendar = Calendar.current
            filteredEvents = events.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            lastFilterDate = date
            view?.success(date: lastFilterDate.toString())
        }
    }
    
    //MARK: - фильтрация Событий по заданному параметру

    func sortEventsWithPredicate(predicate: SortPredicate) {
        switch predicate {
        case .count:
            let sortEvents = filteredEvents?.sorted { $0.peopleAllCountInt < $1.peopleAllCountInt }
            filteredEvents = sortEvents
            view?.success(date: title)
        case .time:
            let sortEvents = filteredEvents?.sorted { $0.time < $1.time }
            filteredEvents = sortEvents
            view?.success(date: title)
        case .address:
            let sortEvents = filteredEvents?.sorted { $0.address < $1.address }
            filteredEvents = sortEvents
            view?.success(date: title)
        case .personal:
//            guard let myID = firebase.currentUser?.uid else { return }
            guard let myID = firebase.currentUserId else { return }
            personlaMode = true
            filteredEvents = filteredEvents?.filter { $0.users.contains(myID) }
            view?.success(date: title)
        case .none:
            personlaMode = false
            filterEventsWithDate(date: lastFilterDate)
        }
        
    }

    //MARK: - Удаление собитыя
    func deleteEvent(eventId: String) {
        guard eventId != "" else {
            router?.showAlertWithTitle("Выберите событие")
            return
        }
        
        // Проверяем, является ли текущий пользователь участником или организатором события
//        guard let currentUserId = firebase.currentUser?.uid else {
        guard let currentUserId = firebase.currentUserId else {
            router?.showAlertWithTitle("Необходимо войти в систему")
            return
        }
        
        guard let event = events?.first(where: { $0.id == eventId }) else {
            router?.showAlertWithTitle("Событие не найдено")
            return
        }
        
        let isOrganizer = event.orgId == currentUserId
        
        guard isOrganizer else {
            router?.showAlertWithTitle("Вы не можете удалить событие, созданное не Вами")
            return
        }
        
        network?.deleteEvent(idEvent: eventId, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
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
        router?.pushProfileVC(model: nil)
    }
    
    //MARK: - Пуш в экран создания события
    func pushCreateEvent() {
//        guard firebase.currentUser?.uid != nil else {
        guard firebase.currentUserId != nil else {
            router?.showAlertWithTitle("Для создания события необходимо зарегестрироваться")
            return
        }
        router?.pushCreateEvent(date: lastFilterDate)
    }
    
    func signOut() {
        router?.showAlertConfigur(title: "Выйти из аккаунта?",
                                  message: "Вы действительно хотите выйти?",
                                  titleActionButton: "Да", handelr: { [weak self] in
            guard let self = self else { return }
            
            if let userID = firebase.currentUserId {
                network?.removeUser(userID: userID, completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success():
                        self.firebase.signOut { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success:
                                self.router?.initialViewController()
                            case .failure(let failure):
                                self.router?.showAlertWithTitle(failure.localizedDescription)
                            }
                        }
                    case .failure(let failure):
                        self.router?.showAlertWithTitle(failure.localizedDescription)
                    }
                })
            } else {
                self.firebase.signOut { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        self.router?.initialViewController()
                    case .failure(let failure):
                        self.router?.showAlertWithTitle(failure.localizedDescription)
                    }
                }
            }
            
        })
    }
    

    //MARK: - Deinit
    deinit {
        print("Deinit HomePresenter")
//        stopRealTimeObservation()
    }

}
