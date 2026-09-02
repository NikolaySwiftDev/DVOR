
import Foundation

enum BaseRegistPosition {
    case email, info, experience, avatar, geo, pushNotif

    var titleMain: String {
        switch self {
        case .email:
            BaseRegistStrings.email
        case .info, .experience:
            BaseRegistStrings.profile
        case .avatar:
            BaseRegistStrings.avatar
        case .geo:
            BaseRegistStrings.city
        case .pushNotif:
            BaseRegistStrings.enableNotifications
        }
    }

    var titleDesc: String {
        switch self {
        case .email:
            BaseRegistStrings.enterEmail
        case .info:
            BaseRegistStrings.enterProfileData
        case .experience:
            BaseRegistStrings.selectExperience
        case .avatar:
            BaseRegistStrings.selectAvatar
        case .geo:
            BaseRegistStrings.selectCity
        case .pushNotif:
            BaseRegistStrings.notificationsDescription
        }
    }

    var page: String {
        switch self {
        case .email:
            "1/6"
        case .info:
            "2/6"
        case .experience:
            "3/6"
        case .avatar:
            "4/6"
        case .geo:
            "5/6"
        case .pushNotif:
            "6/6"
        }
    }

    var progress: Float {
        switch self {
        case .email:
            0.1
        case .info:
            0.3
        case .experience:
            0.5
        case .avatar:
            0.7
        case .geo:
            0.88
        case .pushNotif:
            1
        }
    }
}

fileprivate struct BaseRegistStrings {
    static let email = "base_regist.email".loc
    static let profile = "base_regist.profile".loc
    static let avatar = "base_regist.avatar".loc
    static let city = "base_regist.city".loc
    static let enableNotifications = "base_regist.enable_notifications".loc

    static let enterEmail = "base_regist.enter_email".loc
    static let enterProfileData = "base_regist.enter_profile_data".loc
    static let selectExperience = "base_regist.select_experience".loc
    static let selectAvatar = "base_regist.select_avatar".loc
    static let selectCity = "base_regist.select_city".loc
    static let notificationsDescription = "base_regist.notifications_description".loc
}
