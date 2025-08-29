import Foundation

struct Responsibilities {
    static let responsibilities = [
        "🍟 Встреча игроков",
        "🍟 Раздача жилеток и мячей",
        "🍟 Формирование команд",
        "🍟 Организация матча",
        "🍟 Замена травмированных или отсутствующих игроков"
    ]
}

struct OrganizatorModel: Codable {
    let id: String
    let image: Data?
    let name: String
    let infoOrg: String
}
