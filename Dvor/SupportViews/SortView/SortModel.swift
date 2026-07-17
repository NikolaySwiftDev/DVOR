
import Foundation

enum TypeView: String {
    
    case sort = "sort"
    case filter = "filter"
    
    var title: String {
        rawValue.loc
    }
    
    var sortArray: [SortCellModel] {
        switch self {
        case .sort:
            return [
                SortCellModel(title: "sort.participants_count".loc, predicate: .count),
                SortCellModel(title: "sort.time".loc, predicate: .time),
                SortCellModel(title: "sort.address".loc, predicate: .address),
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
    case none
    case personal
    case count
    case time
    case address
}


