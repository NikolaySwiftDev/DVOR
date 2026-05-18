
import Foundation

enum BaseRegistPosition {
    case email, info, experience, avatar, /*geo,*/ pushNotif
    
    var titleMain: String {
        switch self {
        case .email:
            "Введите почту"
        case .info:
            "Профиль"
        case .experience:
            "Профиль"
        case .avatar:
            "Аватар"
//        case .geo:
//            "Город"
        case .pushNotif:
            "Включите уведомления"
        }
    }
    
    var titleDesc: String {
        switch self {
        case .email:
            "Чтобы войти в приложение"
        case .info:
            "Введите ваши данные"
        case .experience:
            "Выберите опыт игры и вашу позицию"
        case .avatar:
            "Выберите фотографию профиля"
//        case .geo:
//            "Выберите город в котором будете играть"
        case .pushNotif:
            "Приложение ДВОР запрашивает доступ на отправку вам уведомлений"
        }
    }

    var page: String {
        switch self {
        case .email:
            ""
        case .info:
            "1/4"
        case .experience:
            "2/4"
        case .avatar:
            "3/4"
//        case .geo:
//            "4/5"
        case .pushNotif:
            "4/4"
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
//        case .geo:
//            0.8
        case .pushNotif:
            1
        }
    }
    
    var showTitleView: Bool {
        switch self {
        case .email:
            true
        default:
            false
        }
    }
}
