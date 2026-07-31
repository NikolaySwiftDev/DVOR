import Foundation

struct CommentModel: Codable {
    let id: String
    let userId: String
    let userName: String
    let userImage: Data?
    let text: String
    let date: Date
}

extension CommentModel {
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let userId = dictionary["userId"] as? String,
              let userName = dictionary["userName"] as? String,
              let text = dictionary["text"] as? String,
              let timestamp = dictionary["date"] as? TimeInterval else {
            return nil
        }

        self.id = id
        self.userId = userId
        self.userName = userName
        self.text = text
        self.date = Date(timeIntervalSince1970: timestamp)

        if let imageString = dictionary["userImage"] as? String, !imageString.isEmpty {
            self.userImage = Data(base64Encoded: imageString)
        } else {
            self.userImage = nil
        }
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "userName": userName,
            "text": text,
            "date": date.timeIntervalSince1970
        ]

        if let userImage {
            dict["userImage"] = userImage.base64EncodedString()
        }

        return dict
    }
}

enum CommentsError: LocalizedError {
    case invalidEventID
    case invalidCommentID
    case invalidCommentData
 
    var errorDescription: String? {
        switch self {
        case .invalidEventID:
            return "comments.invalid_event_id".loc
        case .invalidCommentID:
            return "comments.invalid_comment_id".loc
        case .invalidCommentData:
            return "comments.invalid_comment_data".loc
        }
    }
}
