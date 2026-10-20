import Foundation
import FirebaseCore
import FirebaseDatabase

protocol FirebaseDataManagerProtocol: AnyObject {
    //Fetch
    func fetchEvents(countryCode: String, date: Date, completion: @escaping (Result<[EventModel], Error>) -> Void)
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
    
    //Attendance & ratings
    func fetchAttendance(idEvent: String, completion: @escaping (Result<[String: Bool], Error>) -> Void)
    func fetchRatings(idEvent: String, completion: @escaping (Result<[String: Int], Error>) -> Void)
    func setAttendance(idEvent: String, idUser: String, attended: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func submitRating(idEvent: String, orgId: String, idUser: String, value: Int, completion: @escaping (Result<Void, Error>) -> Void)


}

final class FirebaseDataManager: FirebaseDataManagerProtocol {

    private let database: DatabaseReference
    private let eventsPath = "events"
    private let usersPath = "users"
    
    init() {
        Database.database().isPersistenceEnabled = true
        database = Database.database(url: FirebaseDataManagerConstants.databaseURL).reference()
    }

    deinit {
//        print("Deinit FirebaseDataManager", Unmanaged.passUnretained(self).toOpaque())
    }
    
    //MARK: - Fetch Events (only the selected country and day)
    func fetchEvents(countryCode: String, date: Date, completion: @escaping (Result<[EventModel], Error>) -> Void) {
        let key = EventModel.countryDayKey(countryCode: countryCode, date: date)

        database.child(eventsPath)
            .queryOrdered(byChild: "countryDay")
            .queryEqual(toValue: key)
            .observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let self = self else { return }
                self.processSnapshot(snapshot, completion: completion)
            }, withCancel: { error in
                completion(.failure(error))
            })
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
    
    //MARK: - Adding a user to an event (atomic, own key only)
    func writeUserToEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(FirebaseDataError.invalidEventID))
            return
        }
        guard !idUser.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }

        let userRef = database.child(eventsPath).child(idEvent).child(usersPath).child(idUser)
        var didAdd = false

        userRef.runTransactionBlock({ currentData in
            didAdd = false

            // Already in the event: keep the original join time (queue order)
            if let existing = currentData.value, !(existing is NSNull) {
                return TransactionResult.abort()
            }

            currentData.value = ServerValue.timestamp()
            didAdd = true
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { [weak self] error, committed, _ in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            if committed && didAdd {
                self.database.child("userEvents").child(idUser).child(idEvent).setValue(true)
                self.database.child(self.usersPath).child(idUser).child("plays")
                    .setValue(ServerValue.increment(1))
            }

            self.fetchEventUserIDs(idEvent: idEvent, completion: completion)
        })
    }
    
    //MARK: - Current participants of an event (ordered by join time)
    private func fetchEventUserIDs(idEvent: String, completion: @escaping (Result<[String], Error>) -> Void) {
        database.child(eventsPath).child(idEvent).child(usersPath)
            .observeSingleEvent(of: .value, with: { snapshot in
                completion(.success(EventModel.parseUserIDs(snapshot.value)))
            }, withCancel: { error in
                completion(.failure(error))
            })
    }

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
            let userIds = EventModel.parseUserIDs((snapshot.value as? [String: Any])?[usersPath])
            
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
    
    //MARK: - Removing a user from an event (atomic, own key only)
    func removeUserFromEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(FirebaseDataError.invalidEventID))
            return
        }
        guard !idUser.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }

        let userRef = database.child(eventsPath).child(idEvent).child(usersPath).child(idUser)
        var didRemove = false

        userRef.runTransactionBlock({ currentData in
            didRemove = false

            guard let existing = currentData.value, !(existing is NSNull) else {
                return TransactionResult.success(withValue: currentData)
            }

            currentData.value = nil
            didRemove = true
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { [weak self] error, committed, _ in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard committed, didRemove else {
                completion(.failure(FirebaseDataError.userNotInEvent))
                return
            }

            self.database.child("userEvents").child(idUser).child(idEvent).removeValue()
            self.decrementPlaysSafely(userId: idUser)
            self.fetchEventUserIDs(idEvent: idEvent, completion: completion)
        })
    }
    
    //MARK: - Removing a user with everything that belongs to them
    func removeUser(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !userID.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }

        // 1. Leave all the events the user has joined
        database.child("userEvents").child(userID).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }

            let joinedIDs = (snapshot.value as? [String: Any])?.keys.map { $0 } ?? []
            let group = DispatchGroup()

            for eventId in joinedIDs {
                group.enter()
                self.removeUserFromEvent(idEvent: eventId, idUser: userID) { _ in group.leave() }
            }

            group.notify(queue: .main) {
                // 2. Delete the events organised by this user
                self.removeOrganizedEvents(orgId: userID) {
                    // 3. Delete the profile and the list of joined events
                    self.database.child(self.usersPath).child(userID).removeValue { error, _ in
                        self.database.child("userEvents").child(userID).removeValue()
                        self.database.child("blocks").child(userID).removeValue()
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }, withCancel: { error in
            completion(.failure(error))
        })
    }

    private func removeOrganizedEvents(orgId: String, completion: @escaping () -> Void) {
        database.child(eventsPath)
            .queryOrdered(byChild: "orgId")
            .queryEqual(toValue: orgId)
            .observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let self = self else { return }

                let eventIDs = snapshot.children.compactMap { ($0 as? DataSnapshot)?.key }
                guard !eventIDs.isEmpty else {
                    completion()
                    return
                }

                let group = DispatchGroup()
                for eventId in eventIDs {
                    group.enter()
                    self.deleteEvent(idEvent: eventId) { _ in group.leave() }
                }
                group.notify(queue: .main, execute: completion)
            }, withCancel: { _ in
                completion()
            })
    }
    
    //MARK: - Has Event On Same Day
    func hasEventOnSameDay(userId: String, date: Date, excludingEventId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        database.child("userEvents").child(userId).observeSingleEvent(of: .value, with: { [weak self] snapshot in
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
                    // Count only events where the user is really listed (userEvents may hold stale entries)
                    if case .success(let event) = result,
                       event.users.contains(userId),
                       calendar.isDate(event.date, inSameDayAs: date) {
                        foundConflict = true
                    }
                }
            }

            group.notify(queue: .main) {
                completion(.success(foundConflict))
            }
        }, withCancel: { error in
            completion(.failure(error))
        })
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
    
    //MARK: - Attendance (set by the organizer)
    func fetchAttendance(idEvent: String, completion: @escaping (Result<[String: Bool], Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(FirebaseDataError.invalidEventID))
            return
        }

        database.child(eventsPath).child(idEvent).child("attendance")
            .observeSingleEvent(of: .value, with: { snapshot in
                let raw = snapshot.value as? [String: Any] ?? [:]
                completion(.success(raw.compactMapValues { $0 as? Bool }))
            }, withCancel: { error in
                completion(.failure(error))
            })
    }

    func setAttendance(idEvent: String, idUser: String, attended: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(FirebaseDataError.invalidEventID))
            return
        }
        guard !idUser.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }

        let attendanceRef = database.child(eventsPath).child(idEvent).child("attendance").child(idUser)
        var previous: Bool?

        attendanceRef.runTransactionBlock({ currentData in
            previous = currentData.value as? Bool
            currentData.value = attended
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { [weak self] error, committed, _ in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard committed else {
                completion(.success(()))
                return
            }

            // Counters follow the change of the mark, so re-marking never double counts
            var delta: [String: Any] = [:]
            switch (previous, attended) {
            case (nil, true):
                delta["attended"] = ServerValue.increment(1)
            case (nil, false):
                delta["noShows"] = ServerValue.increment(1)
            case (true?, false):
                delta["attended"] = ServerValue.increment(-1)
                delta["noShows"] = ServerValue.increment(1)
            case (false?, true):
                delta["noShows"] = ServerValue.increment(-1)
                delta["attended"] = ServerValue.increment(1)
            default:
                break
            }

            guard !delta.isEmpty else {
                completion(.success(()))
                return
            }

            self.database.child(self.usersPath).child(idUser).updateChildValues(delta) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        })
    }

    //MARK: - Ratings (set once by each participant who attended)
    func fetchRatings(idEvent: String, completion: @escaping (Result<[String: Int], Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(FirebaseDataError.invalidEventID))
            return
        }

        database.child(eventsPath).child(idEvent).child("ratings")
            .observeSingleEvent(of: .value, with: { snapshot in
                let raw = snapshot.value as? [String: Any] ?? [:]
                completion(.success(raw.compactMapValues { $0 as? Int }))
            }, withCancel: { error in
                completion(.failure(error))
            })
    }

    func submitRating(idEvent: String, orgId: String, idUser: String, value: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(FirebaseDataError.invalidEventID))
            return
        }
        guard !orgId.isEmpty, !idUser.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }
        guard (1...5).contains(value) else {
            completion(.failure(FirebaseDataError.invalidRating))
            return
        }

        let ratingRef = database.child(eventsPath).child(idEvent).child("ratings").child(idUser)
        var didWrite = false

        ratingRef.runTransactionBlock({ currentData in
            didWrite = false

            // One rating per participant per event
            if let existing = currentData.value, !(existing is NSNull) {
                return TransactionResult.abort()
            }

            currentData.value = value
            didWrite = true
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { [weak self] error, committed, _ in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard committed, didWrite else {
                completion(.failure(FirebaseDataError.alreadyRated))
                return
            }

            let delta: [String: Any] = [
                "ratingSum": ServerValue.increment(NSNumber(value: value)),
                "ratingCount": ServerValue.increment(1)
            ]

            self.database.child(self.usersPath).child(orgId).updateChildValues(delta) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        })
    }
    
    //MARK: - Safe decrement (never goes below 0, never recreates a deleted profile)
    private func decrementPlaysSafely(userId: String) {
        let playsRef = database.child(usersPath).child(userId).child("plays")

        playsRef.runTransactionBlock { currentData in
            // Empty or not yet synced: leave it unchanged (Firebase re-runs with the real value)
            guard let currentValue = currentData.value as? Int else {
                return TransactionResult.success(withValue: currentData)
            }
            currentData.value = max(0, currentValue - 1)
            return TransactionResult.success(withValue: currentData)
        }
    }
}
