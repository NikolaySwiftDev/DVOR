
import Foundation

enum BaseRegistPosition {
    case phone, info, experience, avatar, geo, pushNotif
    
    var titleMain: String {
        switch self {
        case .phone:
            "Введите номер телефона"
        case .info:
            "Профиль"
        case .experience:
            "Профиль"
        case .avatar:
            "Аватар"
        case .geo:
            "Город"
        case .pushNotif:
            "Включите уведомления"
        }
    }
    
    var titleDesc: String {
        switch self {
        case .phone:
            "Чтобы войти в приложение"
        case .info:
            "Введите ваши данные"
        case .experience:
            "Выберите опыт игры и вашу позицию"
        case .avatar:
            "Выберите фотографию профиля"
        case .geo:
            "Выберите город в котором будете играть"
        case .pushNotif:
            "Приложение ДВОР запрашивает доступ на отправку вам уведомлений"
        }
    }

    var page: String {
        switch self {
        case .phone:
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
        case .phone:
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
        switch self {
        case .phone:
            true
        default:
            false
        }
    }
}
