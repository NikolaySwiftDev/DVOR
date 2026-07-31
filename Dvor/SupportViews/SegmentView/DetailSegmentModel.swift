
import Foundation

struct DetailSegmentModel {
    let items = ["Info".loc, "Participants".loc, "Comments".loc]
}

enum DetailSegmentViewPosition: CaseIterable {
    case info, users ,comments
}

