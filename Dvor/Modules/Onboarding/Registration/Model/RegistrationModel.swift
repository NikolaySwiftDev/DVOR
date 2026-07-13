
import Foundation

enum ProfileInfo {
    case position
    case experience
    case city

    var title: String {
        switch self {
        case .position:
            ProfileInfoStrings.positionTitle
        case .experience:
            ProfileInfoStrings.experienceTitle
        case .city:
            ""
        }
    }

    var model: [String] {
        switch self {
        case .position:
            [
                ProfileInfoStrings.goalkeeper,
                ProfileInfoStrings.defender,
                ProfileInfoStrings.midfielder,
                ProfileInfoStrings.forward
            ]

        case .experience:
            [
                ProfileInfoStrings.lessThanYear,
                ProfileInfoStrings.oneTwoYears,
                ProfileInfoStrings.threeFourYears,
                ProfileInfoStrings.fivePlusYears
            ]

        case .city:
            [
                ProfileInfoStrings.city
            ]
        }
    }
}

fileprivate struct ProfileInfoStrings {
    static let positionTitle = "profile.position.title".loc
    static let experienceTitle = "profile.experience.title".loc

    static let goalkeeper = "profile.position.goalkeeper".loc
    static let defender = "profile.position.defender".loc
    static let midfielder = "profile.position.midfielder".loc
    static let forward = "profile.position.forward".loc

    static let lessThanYear = "profile.experience.less_than_year".loc
    static let oneTwoYears = "profile.experience.one_two_years".loc
    static let threeFourYears = "profile.experience.three_four_years".loc
    static let fivePlusYears = "profile.experience.five_plus_years".loc

    static let city = "profile.city".loc
}
