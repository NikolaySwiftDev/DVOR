
import Foundation
import FirebaseCore
import FirebaseDatabase


protocol FirebaseCommentsManagerProtocol: AnyObject {
    func fetchComments(idEvent: String, completion: @escaping (Result<[CommentModel], Error>) -> Void)
    func addComment(idEvent: String, comment: CommentModel, completion: @escaping (Result<CommentModel, Error>) -> Void)
    func deleteComment(idEvent: String, commentId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class FirebaseCommentsManager: FirebaseCommentsManagerProtocol {
    private let database: DatabaseReference
    private let eventsPath = "events"
    private let commentsPath = "comments"
    
    init() {
        database = Database.database(url: FirebaseDataManagerConstants.databaseURL).reference()
        print("Init CommentsManager", Unmanaged.passUnretained(self).toOpaque())
    }

    deinit {
        print("Deinit CommentsManager", Unmanaged.passUnretained(self).toOpaque())
    }
    
    // MARK: - Fetch Comments
    func fetchComments(idEvent: String, completion: @escaping (Result<[CommentModel], Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(CommentsError.invalidEventID))
            return
        }
        
        let commentsRef = database.child(eventsPath).child(idEvent).child(commentsPath)
        
        commentsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            guard snapshot.exists() else {
                completion(.success([]))
                return
            }
            
            var comments: [CommentModel] = []
            
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                      let value = childSnapshot.value as? [String: Any] else {
                    continue
                }
                
                if let comment = CommentModel(from: value) {
                    comments.append(comment)
                } else {
                    print("❌ Failed to parse comment: \(childSnapshot.key)")
                }
            }
            
            let sorted = comments.sorted { $0.date < $1.date }
            completion(.success(sorted))
        }
    }
    
    // MARK: - Add Comment
    func addComment(idEvent: String, comment: CommentModel, completion: @escaping (Result<CommentModel, Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(CommentsError.invalidEventID))
            return
        }
        
        let commentsRef = database.child(eventsPath).child(idEvent).child(commentsPath)
        let newCommentRef = comment.id.isEmpty ? commentsRef.childByAutoId() : commentsRef.child(comment.id)
        
        guard let generatedId = comment.id.isEmpty ? newCommentRef.key : comment.id else {
            completion(.failure(CommentsError.invalidCommentID))
            return
        }
        
        let finalComment = CommentModel(
            id: generatedId,
            userId: comment.userId,
            userName: comment.userName,
            userImage: comment.userImage,
            text: comment.text,
            date: comment.date
        )
        
        newCommentRef.setValue(finalComment.toDictionary()) { [weak self] error, _ in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(finalComment))
            }
        }
    }
    
    // MARK: - Delete Comment
    func deleteComment(idEvent: String, commentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !idEvent.isEmpty else {
            completion(.failure(CommentsError.invalidEventID))
            return
        }
        
        guard !commentId.isEmpty else {
            completion(.failure(CommentsError.invalidCommentID))
            return
        }
        
        let commentRef = database.child(eventsPath).child(idEvent).child(commentsPath).child(commentId)
        
        commentRef.removeValue { [weak self] error, _ in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}


