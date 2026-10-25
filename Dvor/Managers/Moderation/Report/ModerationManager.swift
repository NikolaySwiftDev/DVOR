import Foundation
import FirebaseDatabase


protocol ModerationManagerProtocol: AnyObject {
    func report(_ report: ReportModel, completion: @escaping (Result<Void, Error>) -> Void)
    
    func blockUser(blockerId: String, blockedId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchBlockedUserIDs(userId: String, completion: @escaping (Result<Set<String>, Error>) -> Void)
    
    func unblockUser(blockerId: String, blockedId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class FirebaseModerationManager: ModerationManagerProtocol {

    private let database: DatabaseReference
    private let reportsPath = "reports"
    private let blocksPath = "blocks"

    init() {
        database = Database.database(url: FirebaseDataManagerConstants.databaseURL).reference()
    }

    //MARK: - Report
    func report(_ report: ReportModel, completion: @escaping (Result<Void, Error>) -> Void) {
        database.child(reportsPath).child(report.key).setValue(report.toDictionary()) { error, _ in
            DispatchQueue.main.async {
                guard let error = error else {
                    completion(.success(()))
                    return
                }

                // The rule forbids overwriting an existing report: that is a repeat complaint
                if error.localizedDescription.lowercased().contains("permission") {
                    completion(.failure(ModerationError.alreadyReported))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    //MARK: - Block
    func blockUser(blockerId: String, blockedId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !blockerId.isEmpty, !blockedId.isEmpty, blockerId != blockedId else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }

        database.child(blocksPath).child(blockerId).child(blockedId).setValue(true) { error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    //MARK: - Fetch Blocked User

    func fetchBlockedUserIDs(userId: String, completion: @escaping (Result<Set<String>, Error>) -> Void) {
        guard !userId.isEmpty else {
            completion(.success([]))
            return
        }

        database.child(blocksPath).child(userId).observeSingleEvent(of: .value, with: { snapshot in
            let ids = (snapshot.value as? [String: Any])?.keys.map { $0 } ?? []
            DispatchQueue.main.async {
                completion(.success(Set(ids)))
            }
        }, withCancel: { error in
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        })
    }
    
    //MARK: - Unblock User

    func unblockUser(blockerId: String, blockedId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !blockerId.isEmpty, !blockedId.isEmpty else {
            completion(.failure(FirebaseDataError.invalidUserID))
            return
        }

        database.child(blocksPath).child(blockerId).child(blockedId).removeValue { error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
