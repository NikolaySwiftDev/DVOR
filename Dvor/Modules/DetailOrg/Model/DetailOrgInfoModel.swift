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
    var id: String = ""
    var image: Data? = nil
    var name: String = ""
//    let infoOrg: String

}
