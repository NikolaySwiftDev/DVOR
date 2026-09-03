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
        
    init(view: EventsProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol)
}

final class EventsPresenter: EventsPresenterProtocol {

    weak var view: EventsProtocol?
    private weak var coordinator: AppCoordinatorProtocol?
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
            EventsPresenterStrings.yourEventsOn + lastFilterDate.toString()
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
    
    //MARK: - General processing of results
    private func handleEventsResult(_ result: Result<[EventModel], Error>) {
        switch result {
        case .success(let events):
            self.events = events
            self.filterEventsWithDate(date: lastFilterDate)
            self.sortEventsWithPredicate(predicate: personlaMode ? .personal : lastSortPredicate)
            self.fetchAvatarsForEvents(events)
//            view?.success(date: lastFilterDate.toString())
        case .failure(let error):
            self.router?.showAlertWithTitle(error.localizedDescription)
            self.view?.error(error: error)
        }
    }
    
    //MARK: - General method of sending a request and monitoring the database
    func fetchEvents() {
        network?.fetchEvents(completion: { [weak self] result in
            guard let self = self else { return }
            self.handleEventsResult(result)
        })
    }
    
    private func fetchAvatarsForEvents(_ events: [EventModel]) {
        let allUserIDs = Set(events.flatMap { $0.users })
        
        let idsToFetch = allUserIDs.filter { userAvatars[$0] == nil }
        guard !idsToFetch.isEmpty else { return }
        
        let group = DispatchGroup()
        
        for userID in idsToFetch {
            group.enter()
            network?.fetchUser(idUser: userID) { [weak self] result in
                defer { group.leave() }
                guard let self = self else { return }
                
                if case .success(let user) = result, let data = user.image {
                    self.userAvatars[userID] = data
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.view?.updateAvatars(self.userAvatars)
        }
    }
    
    //MARK: - Filtering Events by Date
    func filterEventsWithDate(date: Date) {
        lastFilterDate = date
        
        guard let events = events else { return }
        guard let myID = firebase.currentUserId, let userCity = firebase.currentCity else {
            view?.success(date: lastFilterDate.toString())
            router?.showAlertWithTitle(EventsPresenterStrings.needToRegiste)
            return
        }

        if personlaMode {
            let calendar = Calendar.current
            filteredEvents = events.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            
            filteredEvents = filteredEvents?.filter { $0.users.contains(myID) }
            lastFilterDate = date
            view?.success(date: title)
        } else {
            let calendar = Calendar.current
            filteredEvents = events.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }

            filteredEvents = filteredEvents?.filter { event in
                let eventCity = CityModel(
                    name: event.city,
                    countryCode: event.countryCode,
                    administrativeArea: event.administrativeArea,
                    latitude: event.latitude,
                    longitude: event.longitude
                )
                return eventCity == userCity
            }
            
            view?.success(date: lastFilterDate.toString())
        }
    }
    
    //MARK: - Filtering Events by a specified parameter

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

    //MARK: - Deleting an event
    func deleteEvent(eventId: String) {
        guard eventId != "" else {
            router?.showAlertWithTitle(EventsPresenterStrings.pleaseSelectEvent)
            return
        }
        
        guard let currentUserId = firebase.currentUserId else {
            router?.showAlertWithTitle(EventsPresenterStrings.needToLogIn)
            return
        }
        
        guard let event = events?.first(where: { $0.id == eventId }) else {
            router?.showAlertWithTitle(EventsPresenterStrings.eventNotFound)
            return
        }
        
        let isOrganizer = event.orgId == currentUserId
        
        guard isOrganizer else {
            router?.showAlertWithTitle(EventsPresenterStrings.cannotDeleteNotOwned)
            return
        }
        
        network?.deleteEvent(idEvent: eventId, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                fetchEvents()
            case .failure(let error):
                router?.showAlertWithTitle(EventsPresenterStrings.deleteError)
                view?.error(error: error)
            }
        })
    }
    
    //MARK: - Display on the map
    func showLocationOnMap(location: String) {
        router?.showLocationOnMap(location: location)
    }
    
    //MARK: - Push to the detail screen
    func pushDetailVC(model: EventModel) {
        let details = model.toDetailModel()
        router?.pushDetailVC(model: details)
    }

    //MARK: - Push to the profile screen
    func pushProfileVC() {
        guard firebase.currentUserId != nil else {
            router?.showAlertWithTitle(EventsPresenterStrings.needToCheck)
            return
        }
        router?.pushProfileVC(model: nil)
    }
    
    //MARK: - Push to the create screen
    func pushCreateEvent() {
        guard firebase.currentUserId != nil else {
            router?.showAlertWithTitle(EventsPresenterStrings.needToRegisterToCreate)
            return
        }
        router?.pushCreateEvent(date: lastFilterDate)
    }

    //MARK: - Deinit
    deinit {
         print("Deinit EventPresenter")
    }
}
