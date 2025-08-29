import Foundation
import FirebaseCore
import FirebaseDatabase

protocol FirebaseDataManagerProtocol: AnyObject {
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void)
    func writeEvents(model: EventModel, completion: @escaping (Result<String, Error>) -> Void)
    func writeUser(model: UserModel, completion: @escaping (Result<String, Error>) -> Void)
    func deleteEvent(idEvent: String, completion: @escaping (Result<String, Error>) -> Void)
    func addUserToEvent(idEvent: String, idUser: String, completion: @escaping (Result<String, Error>) -> Void)
    func getAllUsersFromEvent(usersID: [String], completion: @escaping (Result<[UserModel], any Error>) -> Void)

    func startObservingEvents(completion: @escaping (Result<[EventModel], Error>) -> Void)
    func stopObservingEvents()
}

final class FirebaseDataManager: FirebaseDataManagerProtocol {

    private let database: DatabaseReference
    private let eventsPath = "events"
    private let usersPath = "users"
    private var observationHandle: DatabaseHandle?
    private var observationCompletion: ((Result<[EventModel], Error>) -> Void)?
    
    init() {
        let databaseURL = "https://dvor-496f1-default-rtdb.europe-west1.firebasedatabase.app/"
        Database.database().isPersistenceEnabled = true
        database = Database.database(url: databaseURL).reference()
        checkConnection()
    }
    
    // MARK: - Start Observation Methods
    func startObservingEvents(completion: @escaping (Result<[EventModel], Error>) -> Void) {
        stopObservingEvents()
        
        observationCompletion = completion
        observationHandle = database.child(eventsPath).observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.processSnapshot(snapshot, completion: completion)
        }
    }
    
    //MARK: - Stop Observing Events
    func stopObservingEvents() {
        if let handle = observationHandle {
            database.child(eventsPath).removeObserver(withHandle: handle)
            observationHandle = nil
        }
        observationCompletion = nil
    }
    
    
    //MARK: - Общий метод получения всех событий
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void) {
        database.child(eventsPath).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.processSnapshot(snapshot, completion: completion)
        }
    }
    
    //MARK: - Общий метод получения всех уастников ОДНОГО события
    func getAllUsersFromEvent(usersID: [String], completion: @escaping (Result<[UserModel], Error>) -> Void) {
        let uniqueIDs = Array(Set(usersID)).filter { !$0.isEmpty }
        
        guard !uniqueIDs.isEmpty else {
            completion(.success([]))
            return
        }
        
        // Ограничиваем количество одновременных запросов
        let maxConcurrentRequests = 10
        let usersRef = database.child("users")
        var users: [UserModel] = []
        let semaphore = DispatchSemaphore(value: maxConcurrentRequests)
        let queue = DispatchQueue(label: "com.user.fetch.queue", attributes: .concurrent)
        
        let group = DispatchGroup()
        
        for userID in uniqueIDs {
            group.enter()
            
            queue.async {
                semaphore.wait()
                
                usersRef.child(userID).observeSingleEvent(of: .value) { snapshot in
                    defer {
                        semaphore.signal()
                        group.leave()
                    }
                    
                    if let userData = snapshot.value as? [String: Any],
                       let user = UserModel(from: userData) {
                        DispatchQueue.main.async {
                            users.append(user)
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(users))
        }
    }
  
    //MARK: - Обращение к БД запросом
    private func processSnapshot(_ snapshot: DataSnapshot, completion: @escaping (Result<[EventModel], Error>) -> Void) {
        guard snapshot.exists() else {
            completion(.success([]))
            return
        }
        
        var events: [EventModel] = []
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
               let value = snapshot.value as? [String: Any],
               let event = EventModel(from: value) {
                events.append(event)
            }
        }
        
        completion(.success(events))
    }
    
    //MARK: - Запись События в БД
    func writeEvents(model: EventModel, completion: @escaping (Result<String, Error>) -> Void) {
        let eventRef = database.child(eventsPath).child(model.id)
        eventRef.setValue(model.toDictionary()) { [weak self] error, _ in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Событие добавлено"))
            }
        }
    }
    
    //MARK: - Запись пользователя в БД
    func writeUser(model: UserModel, completion: @escaping (Result<String, any Error>) -> Void) {
        let eventRef = database.child(usersPath).child(model.id)
        eventRef.setValue(model.toDictionary()) { [weak self] error, _ in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Событие добавлено"))
                print("Пользователь добавлен успешно")
            }
        }
    }
    
    //MARK: - Добавление пользоватля к событию в БД
    func addUserToEvent(idEvent: String, idUser: String, completion: @escaping (Result<String, Error>) -> Void) {
        let usersRef = database.child(eventsPath).child(idEvent).child("users")
        
        usersRef.observeSingleEvent(of: .value) { snapshot in
            var currentUsers = snapshot.value as? [String] ?? []
            
            // Проверяем, нет ли уже пользователя
            if !currentUsers.contains(idUser) {
                currentUsers.append(idUser)
            } else {
                completion(.success("Пользователь уже добавлен"))
            }
            
            usersRef.setValue(currentUsers) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success("Пользователь добавлен"))
                }
            }
        }
    }

    //MARK: - удаление события
    func deleteEvent(idEvent eventId: String, completion: @escaping (Result<String, Error>) -> Void) {
        database.child(eventsPath).child(eventId).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Событие успешно удалено"))
            }
        }
    }

    //MARK: - Проверка подключения
    func checkConnection() {
        let connectedRef = database.database.reference(withPath: ".info/connected")
        connectedRef.observe(.value) { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("✅ Connected to Firebase!")
            } else {
                print("❌ Not connected to Firebase")
            }
        }
    }
    
    deinit {
        print("Deinit Firebase real data base")
    }
}
