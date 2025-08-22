
import Foundation

struct DetailModel {
    let items = ["Инфо", "Участники", "Комментарии"]
}

enum DetailViewPosition: CaseIterable {
    case info, users ,comments
}
