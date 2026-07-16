import Foundation

struct Responsibilities {
    static let responsibilities = [
        "organizer.meeting_players".loc,
        "organizer.team_formation".loc,
        "organizer.match_organization".loc,
        "organizer.player_replacement".loc,
    ]
}

struct OrganizatorModel: Codable {
    var id: String = ""
    var image: Data? = nil
    var name: String = ""
    var city: String = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
}
