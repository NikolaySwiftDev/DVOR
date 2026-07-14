import Foundation

struct SegmentViewModel {
    static let model = [
        "events.current".loc,
        "events.yours".loc
    ]
}

struct EventModel: Codable {
    let id: String
    let date: Date
    let time: String
    let name: String
    let format: Int
    let location: String
    let address: String
    let namePlace: String
    let price: Int
    let ownerName: String
    let timeGame: Int
    var users: [String] = []
    let orgId: String
    
    init(id: String = UUID().uuidString,
         date: Date,
         time: String,
         name: String,
         format: Int,
         location: String,
         address: String,
         namePlace: String,
         price: Int,
         ownerName: String,
         timeGame: Int,
//         totalPeopleCount: Int,
         users: [String] = [],
         orgId: String
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.name = name
        self.format = format
        self.location = location
        self.address = address
        self.namePlace = namePlace
        self.price = price
        self.ownerName = ownerName
        self.timeGame = timeGame
//        self.totalPeopleCount = totalPeopleCount
        self.users = users
        self.orgId = orgId
    }
    
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let timestamp = dictionary["date"] as? TimeInterval,
              let time = dictionary["time"] as? String,
              let name = dictionary["name"] as? String,
              let format = dictionary["format"] as? Int,
              let location = dictionary["location"] as? String,
              let address = dictionary["address"] as? String,
              let namePlace = dictionary["namePlace"] as? String,
              let price = dictionary["price"] as? Int,
              let ownerName = dictionary["ownerName"] as? String,
              let timeGame = dictionary["timeGame"] as? Int,
//              let totalPeopleCount = dictionary["totalPeopleCount"] as? Int,
              let orgId = dictionary["orgId"] as? String else {
            return nil
        }
        
        self.id = id
        self.date = Date(timeIntervalSince1970: timestamp)
        self.time = time
        self.name = name
        self.format = format
        self.location = location
        self.address = address
        self.namePlace = namePlace
        self.price = price
        self.ownerName = ownerName
        self.timeGame = timeGame
//        self.totalPeopleCount = totalPeopleCount
        self.users = dictionary["users"] as? [String] ?? []
        self.orgId = orgId
    }
}

extension EventModel {
    var formattedDate: String {
        return date.formattedAsDayMonthYear()
    }
    
    var formattedTime: String {
        return time + "hour".loc
    }
    
    var priceString: String {
        return "\(price)."
    }
    
    var participantsCount: Int {
         return users.count
     }
    
    var totalPeopleCount: Int {
        format * 2
    }
    
    var formatString: String {
        "\(format)x\(format)"
    }

    var peopleAllCountInt: Int {
        totalPeopleCount - participantsCount
    }
    
    var peopleAllCount: String {
        return "\(peopleAllCountInt.placesString)"
    }
    
    var formattedTimeGame: String {
        String(timeGame) + " min"
    }
}

extension EventModel {
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "date": date.timeIntervalSince1970,
            "time": time,
            "name": name,
            "format": format,
            "location": location,
            "address": address,
            "namePlace": namePlace,
            "price": price,
            "ownerName": ownerName,
            "timeGame": timeGame,
//            "totalPeopleCount": totalPeopleCount,
            "users": users,
            "orgId": orgId
        ]
    }
    
    func toDetailModel() -> DetailModel {
        return DetailModel(
            id: self.id,
            name: self.name,
            city: self.location,
            address: self.address,
            namePlace: self.namePlace,
            date: self.date,
            formattedTime: self.formattedTime,
            priceString: self.priceString,
            formattedTimeGame: self.formattedTimeGame,
            peopleAllCount: self.peopleAllCount,
            peopleAllCountInt: self.peopleAllCountInt,
            users: self.users,
            orgID: self.orgId
        )
    }
}


struct EventsPresenterStrings {
    static let yourEventsOn = "your_events_on".loc
    static let pleaseSelectEvent = "please_select_event".loc
    static let needToLogIn = "need_to_log_in".loc
    static let eventNotFound = "event_not_found".loc
    static let cannotDeleteNotOwned = "cannot_delete_not_owned".loc
    static let deleteError = "delete_error".loc
    static let needToRegisterToCreate = "need_to_register_to_create".loc
    static let signOutTitle = "sign_out_title".loc
    static let signOutMessage = "sign_out_message".loc
    static let yes = "yes".loc
}
