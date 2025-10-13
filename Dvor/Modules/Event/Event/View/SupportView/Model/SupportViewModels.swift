
import Foundation

enum TypeView: String {
    case sort = "Сортировка"
    case filter = "Фильтры"
    
    var sortArray: [SortCellModel] {
        switch self {
        case .sort:
            return [
                SortCellModel(title: "По кол-ву участников", predicate: .count),
                SortCellModel(title: "По времени", predicate: .time),
                SortCellModel(title: "По адресу", predicate: .address)
            ]
        case .filter:
            return []
        }
    }
}

//MARK: - Sort Models
struct SortCellModel {
    let title: String
    let predicate: SortPredicate?
}

enum SortPredicate: String {
    case count
    case time
    case address
}


