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
    func removeUser(userID: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    //Update
    func updateUser(userId: String, fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
    
    //Check
    func hasEventOnSameDay(userId: String, date: Date, excludingEventId: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func countEvents(forOrganizer orgId: String, on date: Date, completion: @escaping (Result<Int, Error>) -> Void)


}

final class FirebaseDataManager: FirebaseDataManagerProtocol {

    private let database: DatabaseReference
    private let eventsPath = "events"
    private let usersPath = "users"
    
    init() {
        Database.database().isPersistenceEnabled = true
        database = Database.database(url: FirebaseDataManagerConstants.databaseURL).reference()
        print("Init FirebaseDataManager", Unmanaged.passUnretained(self).toOpaque())
    }

    deinit {
        print("Deinit FirebaseDataManager", Unmanaged.passUnretained(self).toOpaque())
    }
    
    //MARK: - Fetch Events
    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void) {
        database.child(eventsPath).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.processSnapshot(snapshot, completion: completion)
        }
    }
    
    //MARK: - Fetch Event from ID
    func fetchEvent(idEvent: String, completion: @escaping (Result<EventModel, Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(FirebaseDataError.invalidEventID))
            return
        }
        
        let eventRef = database.child(eventsPath).child(idEvent)
        
        eventRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(FirebaseDataError.eventNotFound))
                return
            }
            
            guard let eventData = snapshot.value as? [String: Any],
                  let event = EventModel(from: eventData) else {
                completion(.failure(FirebaseDataError.invalidEventData))
                return
            }
            
            completion(.success(event))
        }
    }
    
    //MARK: - Fetch All Users From Event
    func fetchAllUsersFromEvent(usersID: [String], orgId: String, completion: @escaping (Result<([UserModel], OrganizatorModel?), Error>) -> Void) {
        let uniqueIDs = Array(Set(usersID)).filter { !$0.isEmpty }
        
        guard !uniqueIDs.isEmpty || !orgId.isEmpty else {
            completion(.success(([], nil)))
            return
        }

        let usersRef = database.child(usersPath)
        var users: [UserModel] = []
        var organizator: UserModel?
        let group = DispatchGroup()
        
        for userID in uniqueIDs {
            group.enter()
            
            usersRef.child(userID).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                defer { group.leave() }
                
                if let userData = snapshot.value as? [String: Any],
                   let user = UserModel(from: userData) {
                    DispatchQueue.main.async {
                        users.append(user)
                    }
                }
            }
        }
        
        if !orgId.isEmpty {
            group.enter()
            
            usersRef.child(orgId).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
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
  
    //MARK: - Accessing the database with a query
    private func processSnapshot(_ snapshot: DataSnapshot, completion: @escaping (Result<[EventModel], Error>) -> Void) {
        guard snapshot.exists() else {
            completion(.success([]))
            return
        }

        var events: [EventModel] = []

        for child in snapshot.children {
            guard let snapshot = child as? DataSnapshot else {
                continue
            }

            guard let value = snapshot.value as? [String: Any] else {
                print("❌ \(snapshot.key): value is not [String: Any]")
                continue
            }

            if let event = EventModel(from: value) {
                events.append(event)
            } else {
                print("❌ Failed to parse event: \(snapshot.key)")
                dump(value)
            }
        }

        completion(.success(events))
    }
    
    //MARK: - Getting a single user
    func fetchUser(idUser: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard !idUser.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }
        
        let userRef = database.child(usersPath).child(idUser)
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(FirebaseDataError.userNotFound))
                return
            }
            
            guard let userData = snapshot.value as? [String: Any],
                  let user = UserModel(from: userData) else {
                completion(.failure(FirebaseDataError.invalidUserData))
                return
            }
            
            completion(.success(user))
        }
    }
    
    //MARK: - Recording an Event in the Database
    func writeEvents(model: EventModel, completion: @escaping (Result<String, Error>) -> Void) {
        let eventRef = database.child(eventsPath).child(model.id)
        eventRef.setValue(model.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(FirebaseDataManagerConstants.eventAdded))
            }
        }
    }
    
    //MARK: - User record in the database
    func writeUser(model: UserModel, completion: @escaping (Result<String, any Error>) -> Void) {
        let eventRef = database.child(usersPath).child(model.id)
        eventRef.setValue(model.toDictionary()) {  error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(FirebaseDataManagerConstants.userAdded))
            }
        }
        
    }
    
    //MARK: - Adding a user to an event in the database
    func writeUserToEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let usersRef = database.child(eventsPath).child(idEvent).child(usersPath)
        
        usersRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            var currentUsers = snapshot.value as? [String] ?? []
            
            if currentUsers.contains(idUser) {
                completion(.success(currentUsers))
                return
            }
            
            currentUsers.append(idUser)
            
            usersRef.setValue(currentUsers) { [weak self] error, _ in
                guard let self else { return }
                if let error = error {
                    completion(.failure(error))
                } else {
                    self.database.child(self.usersPath).child(idUser).child("plays")
                        .setValue(ServerValue.increment(1))
                    completion(.success(currentUsers))
                }
            }
        }
        database.child("userEvents").child(idUser).child(idEvent).setValue(true)
    }

    //MARK: - Updating subscribers
    // MARK: - Updating user fields
    func updateUser(userId: String, fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !userId.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }

        database.child(usersPath).child(userId).updateChildValues(fields) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    //MARK: - deleting an event
    func deleteEvent(idEvent eventId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let eventRef = database.child(eventsPath).child(eventId)
        
        eventRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            let userIds = (snapshot.value as? [String: Any])?[usersPath] as? [String] ?? []
            
            eventRef.removeValue { error, _ in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                for userId in userIds {
                    self.database.child("userEvents").child(userId).child(eventId).removeValue()
                    self.decrementPlaysSafely(userId: userId)
                }
                
                completion(.success(FirebaseDataManagerConstants.eventDeleted))
            }
        }
    }
    
    //MARK: - Removing a user from an event
    func removeUserFromEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let usersRef = database.child(eventsPath).child(idEvent).child(usersPath)
        
        usersRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            var currentUsers = snapshot.value as? [String] ?? []
            
            guard let userIndex = currentUsers.firstIndex(of: idUser) else {
                completion(.failure(FirebaseDataError.userNotInEvent))
                return
            }
            
            currentUsers.remove(at: userIndex)
            
            usersRef.setValue(currentUsers) { [weak self] error, _ in
                guard let self else { return }
                if let error = error {
                    completion(.failure(error))
                } else {
                    self.database.child("userEvents").child(idUser).child(idEvent).removeValue()
                    self.decrementPlaysSafely(userId: idUser)
                    completion(.success(currentUsers))
                }
            }
        }
    }
    
    func removeUser(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        database.child("userEvents").child(userID).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            let eventIds = (snapshot.value as? [String: Bool])?.keys.map { $0 } ?? []
            
            let group = DispatchGroup()
            for eventId in eventIds {
                group.enter()
                self.removeUserFromEvent(idEvent: eventId, idUser: userID) { _ in group.leave() }
            }
            
            group.notify(queue: .main) {
                self.database.child(self.usersPath).child(userID).removeValue { error, _ in
                    self.database.child("userEvents").child(userID).removeValue()
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    //MARK: - Has Event On Same Day

    func hasEventOnSameDay(userId: String, date: Date, excludingEventId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        database.child("userEvents").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            
            let eventIds = (snapshot.value as? [String: Bool])?.keys.filter { $0 != excludingEventId } ?? []
            
            guard !eventIds.isEmpty else {
                completion(.success(false))
                return
            }
            
            let calendar = Calendar.current
            var foundConflict = false
            let group = DispatchGroup()
            
            for eventId in eventIds {
                group.enter()
                self.fetchEvent(idEvent: eventId) { result in
                    defer { group.leave() }
                    if case .success(let event) = result,
                       calendar.isDate(event.date, inSameDayAs: date) {
                        foundConflict = true
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(.success(foundConflict))
            }
        }
    }
    
    func countEvents(forOrganizer orgId: String, on date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        database.child(eventsPath)
            .queryOrdered(byChild: "orgId")
            .queryEqual(toValue: orgId)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(.success(0))
                    return
                }
                
                let calendar = Calendar.current
                var count = 0
                
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot,
                          let value = childSnapshot.value as? [String: Any],
                          let event = EventModel(from: value) else { continue }
                    
                    if calendar.isDate(event.date, inSameDayAs: date) {
                        count += 1
                    }
                }
                
                completion(.success(count))
            }
    }
    
    //MARK: - Safe decrement (never goes below 0)
    private func decrementPlaysSafely(userId: String) {
        let playsRef = database.child(usersPath).child(userId).child("plays")
        
        playsRef.runTransactionBlock { currentData in
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = max(0, currentValue - 1)
            return .success(withValue: currentData)
        }
    }
}
