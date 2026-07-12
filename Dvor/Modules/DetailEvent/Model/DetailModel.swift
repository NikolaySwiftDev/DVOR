
import Foundation

struct DetailModel {
    let id: String
    let name: String
    let address: String
    let namePlace: String
    let date: Date
    let formattedTime: String
    let priceString: String
    let formattedTimeGame: String
    let peopleAllCount: String
    let peopleAllCountInt: Int
    let users: [String]
    let orgID: String
}


enum DetailPresenterConstants {
    static let selectEvent = "detail.select_event".loc
    static let addAccount = "detail.add_account".loc
    static let alreadyParticipating = "detail.already_participating".loc

    static let matchReminder = "detail.match_reminder".loc
    static let eventTomorrowAt = "detail.event_tomorrow_at".loc

    static let queueAdded = "detail.queue_added".loc
    static let userAdded = "detail.user_added".loc

    static let saveError = "detail.save_error".loc

    static let notParticipating = "detail.not_participating".loc
    static let unsubscribed = "detail.unsubscribed".loc
    static let deleteError = "detail.delete_error".loc
}
