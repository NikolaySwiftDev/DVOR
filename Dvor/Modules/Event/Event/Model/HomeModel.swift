import Foundation

struct CalendarDateModel {
    let date: Date
    var isSelected: Bool
}

struct EventModel: Codable {
    let id: String
    let date: Date
    let time: String
    let name: String
    let format: String
    let location: String
    let address: String
    let namePlace: String
    let price: Int
    let ownerName: String
    let timeGame: Int
    let totalPeopleCount: Int
    var users: [String] = []
    let orgId: String
    
    init(id: String = UUID().uuidString,
         date: Date,
         time: String,
         name: String,
         format: String,
         location: String,
         address: String,
         namePlace: String,
         price: Int,
         ownerName: String,
         timeGame: Int,
         totalPeopleCount: Int,
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
        self.totalPeopleCount = totalPeopleCount
        self.users = users
        self.orgId = orgId
    }
    
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let timestamp = dictionary["date"] as? TimeInterval,
              let time = dictionary["time"] as? String,
              let name = dictionary["name"] as? String,
              let format = dictionary["format"] as? String,
              let location = dictionary["location"] as? String,
              let address = dictionary["address"] as? String,
              let namePlace = dictionary["namePlace"] as? String,
              let price = dictionary["price"] as? Int,
              let ownerName = dictionary["ownerName"] as? String,
              let timeGame = dictionary["timeGame"] as? Int,
              let totalPeopleCount = dictionary["totalPeopleCount"] as? Int,
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
        self.totalPeopleCount = totalPeopleCount
        self.users = dictionary["users"] as? [String] ?? []
        self.orgId = orgId
    }
}

extension EventModel {
    var formattedDate: String {
        return date.formattedAsDayMonthYear()
    }
    
    var formattedTime: String {
        return time + "ч"
    }
    
    var priceString: String {
        return "\(price) руб."
    }
    
    var participantsCount: Int {
         return users.count
     }

    var peopleAllCountInt: Int {
        totalPeopleCount - participantsCount
    }
    
    var peopleAllCount: String {
        return "еще \(peopleAllCountInt.placesString)"
    }
    
    var formattedTimeGame: String {
        String(timeGame) + " мин"
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
            "totalPeopleCount": totalPeopleCount,
            "users": users,
            "orgId": orgId
        ]
    }
    
    func toDetailModel() -> DetailModel {
        return DetailModel(
            id: self.id,
            name: self.name,
            address: self.address,
            namePlace: self.namePlace,
            date: self.date,
            formattedTime: self.formattedTime,
            priceString: self.priceString,
            formattedTimeGame: self.formattedTimeGame,
            peopleAllCount: self.peopleAllCount,
            users: self.users,
            orgID: self.orgId
        )
    }
}
