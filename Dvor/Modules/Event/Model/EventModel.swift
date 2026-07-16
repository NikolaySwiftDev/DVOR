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
    let city: String
    let countryCode: String
    let administrativeArea: String?
    let latitude: Double
    let longitude: Double
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
         city: String,
         countryCode: String,
         administrativeArea: String?,
         latitude: Double,
         longitude: Double,
         address: String,
         namePlace: String,
         price: Int,
         ownerName: String,
         timeGame: Int,
         users: [String] = [],
         orgId: String
    ) {
        self.id = id
        self.date = date
        self.time = time
        self.name = name
        self.format = format
        self.city = city
        self.countryCode = countryCode
        self.administrativeArea = administrativeArea
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
        self.namePlace = namePlace
        self.price = price
        self.ownerName = ownerName
        self.timeGame = timeGame
        self.users = users
        self.orgId = orgId
        
        
    }
    
    init?(from dictionary: [String: Any]) {

        guard let id = dictionary["id"] as? String else {
            print("❌ Missing id")
            return nil
        }

        guard let timestamp = dictionary["date"] as? TimeInterval else {
            print("❌ Missing date")
            return nil
        }

        guard let time = dictionary["time"] as? String else {
            print("❌ Missing time")
            return nil
        }

        guard let name = dictionary["name"] as? String else {
            print("❌ Missing name")
            return nil
        }

        guard let format = dictionary["format"] as? Int else {
            print("❌ Missing format")
            return nil
        }

        guard let city = dictionary["location"] as? String else {
            print("❌ Missing location")
            return nil
        }

        guard let countryCode = dictionary["countryCode"] as? String else {
            print("❌ Missing countryCode")
            return nil
        }

        let administrativeArea = dictionary["administrativeArea"] as? String

        guard let latitude = (dictionary["latitude"] as? NSNumber)?.doubleValue else {
            print("❌ Missing latitude")
            return nil
        }

        guard let longitude = (dictionary["longitude"] as? NSNumber)?.doubleValue else {
            print("❌ Missing longitude")
            return nil
        }

        guard let address = dictionary["address"] as? String else {
            print("❌ Missing address")
            return nil
        }

        guard let namePlace = dictionary["namePlace"] as? String else {
            print("❌ Missing namePlace")
            return nil
        }

        guard let price = dictionary["price"] as? Int else {
            print("❌ Missing price")
            return nil
        }

        guard let ownerName = dictionary["ownerName"] as? String else {
            print("❌ Missing ownerName")
            return nil
        }

        guard let timeGame = dictionary["timeGame"] as? Int else {
            print("❌ Missing timeGame")
            return nil
        }

        guard let orgId = dictionary["orgId"] as? String else {
            print("❌ Missing orgId")
            return nil
        }

        self.id = id
        self.date = Date(timeIntervalSince1970: timestamp)
        self.time = time
        self.name = name
        self.format = format
        self.city = city
        self.countryCode = countryCode
        self.administrativeArea = administrativeArea
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.namePlace = namePlace
        self.price = price
        self.ownerName = ownerName
        self.timeGame = timeGame
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
        [
            "id": id,
            "date": date.timeIntervalSince1970,
            "time": time,
            "name": name,
            "format": format,
            "location": city,
            "countryCode": countryCode,
            "administrativeArea": administrativeArea as Any,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "namePlace": namePlace,
            "price": price,
            "ownerName": ownerName,
            "timeGame": timeGame,
            "users": users,
            "orgId": orgId
        ]
    }
    
    func toDetailModel() -> DetailModel {
        return DetailModel(
            id: self.id,
            name: self.name,
            city: self.city,
            countryCode: self.countryCode,
            administrativeArea: self.administrativeArea ?? "",
            latitude: self.latitude,
            longitude: self.longitude,
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
