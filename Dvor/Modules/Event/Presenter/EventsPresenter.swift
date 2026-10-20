import Foundation

protocol EventsProtocol: AnyObject {
    func load()
    func didLoad()
    func success(date: String)
    func error(error: Error)
    func updateAvatars(_ avatars: [String: Data]) 
}

protocol EventsPresenterProtocol: AnyObject {
    var events: [EventModel]? { get set }
    var userAvatars: [String: Data] { get }
    var filteredEvents: [EventModel]? { get set }
        
    func getTitle() -> String
    func fetchEvents()
    func filterEventsWithDate(date: Date)
    func sortEventsWithPredicate(predicate: SortPredicate)
    func deleteEvent(eventId: String)
    func canDeleteEvent(_ event: EventModel) -> Bool
    
    func showLocationOnMap(location: String)
    func pushDetailVC(model: EventModel)
    func pushProfileVC()
    func pushCreateEvent()
    func pushEventsMapVC()
        
    init(view: EventsProtocol,
         router: RouterMainProtocol,
         network: FirebaseDataManagerProtocol,
         firebase: FirebaseAuthManagerProtocol,
         storage: CityStorageProtocol?,
         coordinator: AppCoordinatorProtocol?,
         moderation: ModerationManagerProtocol?

    )
}

final class EventsPresenter: EventsPresenterProtocol {

    var events: [EventModel]?
    var filteredEvents: [EventModel]?
    
    private weak var view: EventsProtocol?
    private weak var coordinator: AppCoordinatorProtocol?

    private let router: RouterMainProtocol?
    private let network: FirebaseDataManagerProtocol?
    private let firebase: FirebaseAuthManagerProtocol
    private let storage: CityStorageProtocol?
    private let moderation: ModerationManagerProtocol?
    

    private(set) var userAvatars: [String: Data] = [:]
    private var blockedIDs: Set<String> = []

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
                  firebase: FirebaseAuthManagerProtocol,
                  storage: CityStorageProtocol?,
                  coordinator: AppCoordinatorProtocol?,
                  moderation: ModerationManagerProtocol?
    ) {
        self.view = view
        self.router = router
        self.network = network
        self.firebase = firebase
        self.storage = storage
        self.coordinator = coordinator
        self.moderation = moderation
    }
    
    //MARK: - General processing of results
    private func handleEventsResult(_ result: Result<[EventModel], Error>, requestedDate: Date) {
        // Ignore a stale response if the user has already switched to another day
        guard Calendar.current.isDate(requestedDate, inSameDayAs: lastFilterDate) else { return }

        switch result {
        case .success(let events):
            self.events = events
            self.applyDayFilter(date: lastFilterDate)
            self.sortEventsWithPredicate(predicate: personlaMode ? .personal : lastSortPredicate)
            self.fetchAvatarsForEvents(events)
        case .failure(let error):
            self.router?.showAlertWithTitle(error.localizedDescription)
            self.view?.error(error: error)
        }
    }
    
    func getTitle() -> String {
        title
    }
        
    //MARK: - Request events for the current country and the selected day
    func fetchEvents() {
        view?.load()
        guard let city = storage?.currentCity else {
            events = []
            filteredEvents = []
            view?.success(date: title)
            view?.didLoad()
            return
        }

        let requestedDate = lastFilterDate
        var fetched: Result<[EventModel], Error>?
        let group = DispatchGroup()

        group.enter()
        network?.fetchEvents(countryCode: city.countryCode, date: requestedDate, completion: { result in
            fetched = result
            group.leave()
        })

        group.enter()
        loadBlockedUserIDs { group.leave() }

        group.notify(queue: .main) { [weak self] in
            guard let self = self, let result = fetched else { return }
            self.handleEventsResult(result, requestedDate: requestedDate)
            view?.didLoad()
        }
    }

    private func loadBlockedUserIDs(completion: @escaping () -> Void) {
        guard let myID = firebase.currentUserId else {
            completion()
            return
        }

        moderation?.fetchBlockedUserIDs(userId: myID) { [weak self] result in
            if case .success(let ids) = result {
                self?.blockedIDs = ids
            }
            completion()
        }
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
        let isAnotherDay = !Calendar.current.isDate(date, inSameDayAs: lastFilterDate)
        lastFilterDate = date

        if isAnotherDay {
            fetchEvents()
        } else {
            applyDayFilter(date: date)
        }
    }
    
    private func applyDayFilter(date: Date) {
        guard let events = events else { return }
        guard let myID = firebase.currentUserId else {
            view?.success(date: lastFilterDate.toString())
            router?.showAlertWithTitle(EventsPresenterStrings.needToRegiste)
            return
        }

        let calendar = Calendar.current
        let dayEvents = events.filter { event in
            guard calendar.isDate(event.date, inSameDayAs: date) else { return false }
            guard blockedIDs.contains(event.orgId) else { return true }
            // The event of a blocked organizer stays visible only if I am already in it
            return event.users.contains(myID)
        }

        view?.load()
        if personlaMode {
            filteredEvents = dayEvents.filter { $0.users.contains(myID) }
            view?.success(date: title)
            view?.didLoad()
        } else {
            let userCity = storage?.currentCity

            filteredEvents = dayEvents.filter { event in
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
            view?.didLoad()
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
    
    //MARK: - Only the organizer can delete an event
    func canDeleteEvent(_ event: EventModel) -> Bool {
        guard let currentUserId = firebase.currentUserId else { return false }
        return event.orgId == currentUserId
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
            router?.showAlertConfigur(title: EventsPresenterStrings.needToRegisterToCreate,
                                      message: EventsPresenterStrings.logout,
                                      titleActionButton: "Register".loc,
                                      handelr: { [weak self] in
                guard let self = self else { return }
                coordinator?.showRegistration()
            })
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
    
    //MARK: - Push to the map screen
    func pushEventsMapVC() {
        guard let events = filteredEvents, !events.isEmpty else {
            router?.showAlertWithTitle("Error - no events")
            return
        }
        router?.pushEventsMapVC(events: events)
    }

    //MARK: - Deinit
    deinit {
        //        print(#function, self)
    }
}
