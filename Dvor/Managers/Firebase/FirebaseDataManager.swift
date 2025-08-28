import Foundation
import FirebaseCore
import FirebaseDatabase

protocol FirebaseDataManagerProtocol: AnyObject {
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void)
    func writeEvents(model: EventModel, completion: @escaping (Result<String, Error>) -> Void)
    func deleteEvent(eventId: String, completion: @escaping (Result<String, Error>) -> Void)
    

    func startObservingEvents(completion: @escaping (Result<[EventModel], Error>) -> Void)
    func stopObservingEvents()
}

final class FirebaseDataManager: FirebaseDataManagerProtocol {

    private let database: DatabaseReference
    private let eventsPath = "events"
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
    
    
    //MARK: - Общий метод получения данных
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void) {
        database.child(eventsPath).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.processSnapshot(snapshot, completion: completion)
        }
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
    
    //MARK: - удаление события
    func deleteEvent(eventId: String, completion: @escaping (Result<String, Error>) -> Void) {
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
}
