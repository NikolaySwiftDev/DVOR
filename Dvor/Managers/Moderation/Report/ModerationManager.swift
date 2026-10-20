import Foundation
import FirebaseDatabase


protocol ModerationManagerProtocol: AnyObject {
    func report(_ report: ReportModel, completion: @escaping (Result<Void, Error>) -> Void)
}

final class FirebaseModerationManager: ModerationManagerProtocol {

    private let database: DatabaseReference
    private let reportsPath = "reports"

    init() {
        database = Database.database(url: FirebaseDataManagerConstants.databaseURL).reference()
    }

    //MARK: - Report
    func report(_ report: ReportModel, completion: @escaping (Result<Void, Error>) -> Void) {
        database.child(reportsPath).child(report.key).setValue(report.toDictionary()) { [weak self] error, _ in
            guard let sefl = self else { return }
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
}
