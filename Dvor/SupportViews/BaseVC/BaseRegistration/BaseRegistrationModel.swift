
import Foundation

enum BaseRegistPosition {
    case email, info, experience, avatar, geo, pushNotif

    var titleMain: String {
        switch self {
        case .email:
            BaseRegistStrings.enterEmail
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
            BaseRegistStrings.enterEmailDescription
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
            ""
        case .info:
            "1/5"
        case .experience:
            "2/5"
        case .avatar:
            "3/5"
        case .geo:
            "4/5"
        case .pushNotif:
            "5/5"
        }
    }

    var progress: Float {
        switch self {
        case .email:
            0
        case .info:
            0.2
        case .experience:
            0.4
        case .avatar:
            0.6
        case .geo:
            0.8
        case .pushNotif:
            1
        }
    }

    var showTitleView: Bool {
        self == .email
    }
}

fileprivate struct BaseRegistStrings {
    static let enterEmail = "base_regist.enter_email".loc
    static let profile = "base_regist.profile".loc
    static let avatar = "base_regist.avatar".loc
    static let city = "base_regist.city".loc
    static let enableNotifications = "base_regist.enable_notifications".loc

    static let enterEmailDescription = "base_regist.enter_email_description".loc
    static let enterProfileData = "base_regist.enter_profile_data".loc
    static let selectExperience = "base_regist.select_experience".loc
    static let selectAvatar = "base_regist.select_avatar".loc
    static let selectCity = "base_regist.select_city".loc
    static let notificationsDescription = "base_regist.notifications_description".loc
}
