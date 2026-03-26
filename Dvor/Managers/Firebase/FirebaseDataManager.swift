import Foundation
import FirebaseCore
import FirebaseDatabase

protocol FirebaseDataManagerProtocol: AnyObject {
    //Fetch
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void)
    func fetchEvent(idEvent: String, completion: @escaping (Result<EventModel, Error>) -> Void)
    func fetchUser(idUser: String, completion: @escaping (Result<UserModel, Error>) -> Void)
    func fetchAllUsersFromEvent(usersID: [String], orgId: String, completion: @escaping (Result<([UserModel], OrganizatorModel?), Error>) -> Void)
    
    //Write
    func writeEvents(model: EventModel, completion: @escaping (Result<String, Error>) -> Void)
    func writeUser(model: UserModel, completion: @escaping (Result<String, Error>) -> Void)
    func writeUserToEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void)

    //Delete
    func deleteEvent(idEvent: String, completion: @escaping (Result<String, Error>) -> Void)
    func removeUserFromEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void)
    
    //Update
    func updateUserFollowers()

}

final class FirebaseDataManager: FirebaseDataManagerProtocol {

    private let database: DatabaseReference
    private let eventsPath = "events"
    private let usersPath = "users"
    
    init() {
        let databaseURL = "https://dvor-496f1-default-rtdb.europe-west1.firebasedatabase.app/"
        Database.database().isPersistenceEnabled = true
        database = Database.database(url: databaseURL).reference()
//        checkConnection()
    }
    
    //MARK: - Общий метод получения всех событий
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void) {
        database.child(eventsPath).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.processSnapshot(snapshot, completion: completion)
        }
    }
    
    //MARK: - Получение одного события по ID
    func fetchEvent(idEvent: String, completion: @escaping (Result<EventModel, Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(NSError(domain: "InvalidEventID", code: 400, userInfo: [NSLocalizedDescriptionKey: "ID события не может быть пустым"])))
            return
        }
        
        let eventRef = database.child(eventsPath).child(idEvent)
        
        eventRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(NSError(domain: "EventNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Событие не найдено"])))
                return
            }
            
            guard let eventData = snapshot.value as? [String: Any],
                  let event = EventModel(from: eventData) else {
                completion(.failure(NSError(domain: "InvalidEventData", code: 500, userInfo: [NSLocalizedDescriptionKey: "Неверный формат данных события"])))
                return
            }
            
            completion(.success(event))
        }
    }
    
    //MARK: - Общий метод получения всех участников ОДНОГО события + организатора
    func fetchAllUsersFromEvent(usersID: [String], orgId: String, completion: @escaping (Result<([UserModel], OrganizatorModel?), Error>) -> Void) {
        let uniqueIDs = Array(Set(usersID)).filter { !$0.isEmpty }
        
        // Проверяем, есть ли хотя бы участники или организатор
        guard !uniqueIDs.isEmpty || !orgId.isEmpty else {
            completion(.success(([], nil)))
            return
        }

        let usersRef = database.child("users")
        var users: [UserModel] = []
        var organizator: UserModel?
        let group = DispatchGroup()
        
        // Загружаем участников
        for userID in uniqueIDs {
            group.enter()
            
            usersRef.child(userID).observeSingleEvent(of: .value) { snapshot in
                defer { group.leave() }
                
                if let userData = snapshot.value as? [String: Any],
                   let user = UserModel(from: userData) {
                    DispatchQueue.main.async {
                        users.append(user)
                    }
                }
            }
        }
        
        // Загружаем организатора, если указан
        if !orgId.isEmpty {
            group.enter()
            
            usersRef.child(orgId).observeSingleEvent(of: .value) { snapshot in
                defer { group.leave() }
                
                if let orgData = snapshot.value as? [String: Any],
                   let org = UserModel(from: orgData) {
                    DispatchQueue.main.async {
                        organizator = org
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success((users, organizator?.toOrgModel())))
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
    
    //MARK: - Получение одного пользователя
    func fetchUser(idUser: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard !idUser.isEmpty else {
            completion(.failure(NSError(domain: "InvalidUserID", code: 400, userInfo: [NSLocalizedDescriptionKey: "ID пользователя не может быть пустым"])))
            return
        }
        
        let userRef = database.child("users").child(idUser)
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            // Проверяем, что пользователь существует
            guard snapshot.exists() else {
                completion(.failure(NSError(domain: "UserNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"])))
                return
            }
            
            // Проверяем, что данные есть и их можно распарсить
            guard let userData = snapshot.value as? [String: Any],
                  let user = UserModel(from: userData) else {
                completion(.failure(NSError(domain: "InvalidUserData", code: 500, userInfo: [NSLocalizedDescriptionKey: "Неверный формат данных пользователя"])))
                return
            }
            
            completion(.success(user))
        }
    }
    
    //MARK: - Запись События в БД
    func writeEvents(model: EventModel, completion: @escaping (Result<String, Error>) -> Void) {
        let eventRef = database.child(eventsPath).child(model.id)
        eventRef.setValue(model.toDictionary()) { /*[weak self]*/ error, _ in
//            guard let self = self else { return }
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
        eventRef.setValue(model.toDictionary()) { /*[weak self]*/ error, _ in
//            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Событие добавлено"))
                print("Пользователь добавлен успешно")
            }
        }
    }
    
    //MARK: - Добавление пользоватля к событию в БД
    func writeUserToEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let usersRef = database.child(eventsPath).child(idEvent).child("users")
        
        usersRef.observeSingleEvent(of: .value) { snapshot in
            var currentUsers = snapshot.value as? [String] ?? []
            
            // Проверяем, нет ли уже пользователя
            if currentUsers.contains(idUser) {
                completion(.success(currentUsers)) // Возвращаем текущий список
                return
            }
            
            // Добавляем пользователя
            currentUsers.append(idUser)
            
            usersRef.setValue(currentUsers) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(currentUsers)) // Возвращаем обновленный список
                }
            }
        }
    }

    //MARK: - Обновление подписчиков
    func updateUserFollowers() {
        print("Update users followers")
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
    
    //MARK: - Удаление пользователя из события
    func removeUserFromEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let usersRef = database.child(eventsPath).child(idEvent).child("users")
        
        usersRef.observeSingleEvent(of: .value) { snapshot in
            var currentUsers = snapshot.value as? [String] ?? []
            
            // Проверяем, есть ли пользователь в списке
            guard let userIndex = currentUsers.firstIndex(of: idUser) else {
                completion(.failure(NSError(domain: "UserNotInEvent", code: 404, userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден в событии"])))
                return
            }
            
            // Удаляем пользователя
            currentUsers.remove(at: userIndex)
            
            usersRef.setValue(currentUsers) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(currentUsers)) // Возвращаем обновленный список
                }
            }
        }
    }

    //MARK: - Проверка подключения
//    func checkConnection() {
//        let connectedRef = database.database.reference(withPath: ".info/connected")
//        connectedRef.observe(.value) { snapshot in
//            if let connected = snapshot.value as? Bool, connected {
//                print("✅ Connected to Firebase!")
//            } else {
//                print("❌ Not connected to Firebase")
//            }
//        }
//    }
    
    deinit {
        print("Deinit Firebase real data base")
    }
}
