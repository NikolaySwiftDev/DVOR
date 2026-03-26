import Foundation

struct UserModel: Codable {
    var id: String
    let image: Data?
    let name: String
    let surname: String
    let dateBirthday: Date
    let mobile: String
    let experience: String
    let city: String
    var email: String = ""
    var gender: String = "муж"
    
    // for card
    var position: String
    var followers: Int = 0
    var following: Int = 0
    var club: String = ""
    var progress: Float = 50
    var hasTicket: Bool = false
    var isChecked: Bool = false
    
    // for game
    var plays: Int = 0
    var level: Double = 50
    var mvpCount: Int = 0
    var mvpNominations: Int = 0
    
    init(
        id: String,
        image: Data? = nil,
        name: String,
        surname: String,
        dateBirthday: Date,
        mobile: String,
        experience: String,
        city: String,
        email: String = "",
        gender: String = "муж",
        position: String,
        followers: Int = 0,
        following: Int = 0,
        club: String = "",
        progress: Float = 50,
        hasTicket: Bool = false,
        isChecked: Bool = false,
        plays: Int = 0,
        level: Double = 50,
        mvpCount: Int = 0,
        mvpNominations: Int = 0
    ) {
        self.id = id
        self.image = image
        self.name = name
        self.surname = surname
        self.dateBirthday = dateBirthday
        self.mobile = mobile
        self.experience = experience
        self.city = city
        self.email = email
        self.gender = gender
        self.position = position
        self.followers = followers
        self.following = following
        self.club = club
        self.progress = progress
        self.hasTicket = hasTicket
        self.isChecked = isChecked
        self.plays = plays
        self.level = level
        self.mvpCount = mvpCount
        self.mvpNominations = mvpNominations
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "image": image?.base64EncodedString() ?? "", // Конвертируем Data в Base64
            "name": name,
            "surname": surname,
            "dateBirthday": dateBirthday.timeIntervalSince1970, // Дата в timestamp
            "mobile": mobile,
            "experience": experience,
            "city": city,
            "email": email,
            "gender": gender,
            "position": position,
            "followers": followers,
            "following": following,
            "club": club,
            "progress": progress,
            "hasTicket": hasTicket,
            "isChecked": isChecked,
            "plays": plays,
            "level": level,
            "mvpCount": mvpCount,
            "mvpNominations": mvpNominations
        ]
    }
    
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let surname = dictionary["surname"] as? String,
              let timestamp = dictionary["dateBirthday"] as? TimeInterval,
              let mobile = dictionary["mobile"] as? String,
              let experience = dictionary["experience"] as? String,
              let city = dictionary["city"] as? String,
              let position = dictionary["position"] as? String else {
            return nil
        }
        
        self.id = id
        
        // Обрабатываем опциональные поля
        if let imageString = dictionary["image"] as? String, !imageString.isEmpty {
            self.image = Data(base64Encoded: imageString)
        } else {
            self.image = nil
        }
        
        self.name = name
        self.surname = surname
        self.dateBirthday = Date(timeIntervalSince1970: timestamp)
        self.mobile = mobile
        self.experience = experience
        self.city = city
        self.email = dictionary["email"] as? String ?? ""
        self.gender = dictionary["gender"] as? String ?? "муж"
        self.position = position
        self.followers = dictionary["followers"] as? Int ?? 0
        self.following = dictionary["following"] as? Int ?? 0
        self.club = dictionary["club"] as? String ?? ""
        self.progress = dictionary["progress"] as? Float ?? 50
        self.hasTicket = dictionary["hasTicket"] as? Bool ?? false
        self.isChecked = dictionary["isChecked"] as? Bool ?? false
        self.plays = dictionary["plays"] as? Int ?? 0
        self.level = dictionary["level"] as? Double ?? 50
        self.mvpCount = dictionary["mvpCount"] as? Int ?? 0
        self.mvpNominations = dictionary["mvpNominations"] as? Int ?? 0
    }
}

// MARK: - Вспомогательные методы
extension UserModel {
    // Полное имя
    var fullName: String {
        return "\(name) \(surname)"
    }
    
    // Возраст пользователя
    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateBirthday, to: now)
        return ageComponents.year ?? 0
    }
}

extension UserModel {
    func toOrgModel() -> OrganizatorModel {
        return OrganizatorModel(id: self.id,
                                image: self.image,
                                name: self.name
                                )
    }
}
