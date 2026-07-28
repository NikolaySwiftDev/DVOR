import Foundation

struct UserModel: Codable {
    var id: String
    let image: Data?
    let name: String
    let experience: String
    
    //For geo
    let city: String
    let countryCode: String
    let administrativeArea: String?
    let latitude: Double?
    let longitude: Double?

    var gender: String = "m"

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
        experience: String,
        city: String,
        countryCode: String,
        administrativeArea: String?,
        latitude: Double,
        longitude: Double,
        gender: String = "m",
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
        self.experience = experience
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.countryCode = countryCode
        self.administrativeArea = administrativeArea
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
        [
            "id": id,
            "image": image?.base64EncodedString() ?? "",
            "name": name,
            "experience": experience,
            "city": city,
            "latitude": latitude as Any,
            "longitude": longitude as Any,
            "countryCode": countryCode,
            "administrativeArea": administrativeArea as Any,
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
              let experience = dictionary["experience"] as? String,
              let city = dictionary["city"] as? String,
              let position = dictionary["position"] as? String else {
            return nil
        }

        self.id = id

        if let imageString = dictionary["image"] as? String, !imageString.isEmpty {
            self.image = Data(base64Encoded: imageString)
        } else {
            self.image = nil
        }

        self.name = name
        self.experience = experience
        self.city = city
        self.countryCode = dictionary["countryCode"] as? String ?? ""
        self.administrativeArea = dictionary["administrativeArea"] as? String
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double

        self.gender = dictionary["gender"] as? String ?? "m"
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

// MARK: - Auxiliary methods
extension UserModel {
    var fullName: String {
        return "\(name)"
    }
}

extension UserModel {
    func toOrgModel() -> OrganizatorModel {
        return OrganizatorModel(id: self.id,
                                image: self.image,
                                name: self.name,
                                city: self.city,
                                latitude: self.latitude,
                                longitude: self.longitude
        )
    }
    
    func toCityModel() -> CityModel {
        CityModel(name: self.name,
                  countryCode: self.countryCode,
                  administrativeArea: self.administrativeArea,
                  latitude: self.latitude ?? 0,
                  longitude: self.longitude ?? 0)
    }
}
