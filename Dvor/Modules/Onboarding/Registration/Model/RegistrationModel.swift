
import Foundation

enum ProfileInfo {
    case position
    case experience
    case city
    
    var title: String {
        switch self {
        case .position:
            "Позиция"
        case .experience:
            "Опыт игры"
        case .city:
            ""
        }
    }
    
    var model: [String] {
        switch self {
        case .position:
            ["Вратарь", "Защитник", "Полузащитник", "Нападающий"]
        case .experience:
            ["Меньше года", "1-2 года", "3-4 года", "5+ лет"]
        case .city:
            ["Санкт-Петербург"]
        }
    }
}
