import Foundation

struct CalendarDateModel {
    let date: Date
    var isSelected: Bool
}

struct EventModel: Codable {
    let date: Date
    let time: String
    let name: String
    let format: String
    let location: String
    let address: String
    let namePlace: String
    let price: Int
    let peopleCount: Int
    let ownerName: String
    let timeGame: Int
    let totlePeoplaCount: Int
    
    // Добавляем уникальный идентификатор
    let id: String
    
    init(id: String = UUID().uuidString,
         date: Date,
         time: String,
         name: String,
         format: String,
         location: String,
         address: String,
         namePlace: String,
         price: Int,
         peopleCount: Int,
         ownerName: String,
         timeGame: Int,
         totlePeoplaCount: Int
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
        self.peopleCount = peopleCount
        self.ownerName = ownerName
        self.timeGame = timeGame
        self.totlePeoplaCount = totlePeoplaCount
    }
    
    // Преобразование в словарь для Firebase
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "date": date.timeIntervalSince1970, // Сохраняем как timestamp
            "time": time,
            "name": name,
            "format": format,
            "location": location,
            "address": address,
            "namePlace": namePlace,
            "price": price,
            "peopleCount": peopleCount,
            "ownerName": ownerName,
            "timeGame": timeGame,
            "totlePeoplaCount": totlePeoplaCount,
        ]
    }
    
    // Инициализация из словаря Firebase
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
              let peopleCount = dictionary["peopleCount"] as? Int,
              let ownerName = dictionary["ownerName"] as? String,
              let timeGame = dictionary["timeGame"] as? Int,
              let totlePeoplaCount = dictionary["totlePeoplaCount"] as? Int else
        {
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
        self.peopleCount = peopleCount
        self.ownerName = ownerName
        self.timeGame = timeGame
        self.totlePeoplaCount = totlePeoplaCount
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
    
    var peopleAllCount: String {
        return "\(peopleCount) / \(totlePeoplaCount)"
    }
    
    var formattedTimeGame: String {
        String(timeGame)
    }
}

struct EventDetail: Codable {
    let users: [UserModel]
    let org: OrganizatorModel
}

struct UserModel: Codable {
    let image: Data?
    let age: Int
    let followers: Int
    let following: Int
    let club: String
    let name: String
    let surname: String
    let email: String
    let dateBirthday: String
    let mobile: String
    let gender: String
    let progress: Float
    let position: String
    let hasTicket: Bool
    let isChecked: Bool
    let stats: UserStats
}

struct UserStats: Codable {
    let plays: Int
    let level: Double
    let mvpCount: Int
    let mvpNominations: Int
    let attendance: String
}

struct OrganizatorModel: Codable {
    let image: Data?
    let name: String
    let infoOrg: String
}

