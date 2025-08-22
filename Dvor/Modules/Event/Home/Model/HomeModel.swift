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
    let iconName: String
    let price: Int
    let peopleCount: Int
    let ownerName: String?
    let ownerImage: String?
    let detail: EventDetail
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

