
import Foundation

//MARK: - Constants
struct FirebaseDataManagerConstants {
    
    static let databaseURL = "https://dvor-496f1-default-rtdb.europe-west1.firebasedatabase.app/"
    
    static let invalidEventId = "firebase.invalid_event_id".loc
    static let eventNotFound = "firebase.event_not_found".loc
    static let invalidEventData = "firebase.invalid_event_data".loc

    static let invalidUserId = "firebase.invalid_user_id".loc
    static let userNotFound = "firebase.user_not_found".loc
    static let invalidUserData = "firebase.invalid_user_data".loc
    static let userNotFoundInEvent = "firebase.user_not_found_in_event".loc

    static let eventAdded = "firebase.event_added".loc
    static let userAdded = "firebase.user_added".loc
    static let eventDeleted = "firebase.event_deleted".loc
}

enum FirebaseDataError: LocalizedError {
    case invalidEventID
    case eventNotFound
    case invalidEventData

    case invalidUserID
    case userNotFound
    case invalidUserData
    case userNotInEvent

    var errorDescription: String? {
        switch self {
        case .invalidEventID:
            return FirebaseDataManagerConstants.invalidEventId
        case .eventNotFound:
            return FirebaseDataManagerConstants.eventNotFound
        case .invalidEventData:
            return FirebaseDataManagerConstants.invalidEventData

        case .invalidUserID:
            return FirebaseDataManagerConstants.invalidUserId
        case .userNotFound:
            return FirebaseDataManagerConstants.userNotFound
        case .invalidUserData:
            return FirebaseDataManagerConstants.invalidUserData
        case .userNotInEvent:
            return FirebaseDataManagerConstants.userNotFoundInEvent
        }
    }
}
