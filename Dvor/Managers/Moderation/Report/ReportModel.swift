import Foundation
import FirebaseDatabase

enum ModerationError: LocalizedError {
    case alreadyReported

    var errorDescription: String? {
        switch self {
        case .alreadyReported: return ModerationStrings.reportAlready
        }
    }
}

struct ReportModel {

    enum TargetType: String {
        case comment
        case user
        case event
    }

    enum Reason: String, CaseIterable {
        case spam
        case abuse
        case inappropriate
        case other

        var title: String { "report.reason.\(rawValue)".loc }
    }

    let reporterId: String
    let targetType: TargetType
    let targetId: String          // comment id (or user id later)
    let reportedUserId: String
    let eventId: String?
    let reason: Reason
    let contentText: String?      // snapshot of the comment, stays visible even if the author deletes it

    /// One report per (reporter, target): matches the rule on the server
    var key: String { "\(reporterId)_\(targetId)" }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "reporterId": reporterId,
            "targetType": targetType.rawValue,
            "targetId": targetId,
            "reportedUserId": reportedUserId,
            "reason": reason.rawValue,
            "createdAt": ServerValue.timestamp()
        ]
        if let eventId = eventId { dict["eventId"] = eventId }
        if let contentText = contentText { dict["contentText"] = String(contentText.prefix(1000)) }
        return dict
    }
}

enum ModerationStrings {
    static let reportTitle = "report.title".loc
    static let reportMessage = "report.message".loc
    static let reportSent = "report.sent".loc
    static let reportAlready = "report.already".loc
    static let blockTitle = "block.title".loc
    static let blockMessage = "block.message".loc
    static let blockAction = "block.action".loc
}
