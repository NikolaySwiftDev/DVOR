import Foundation
import FirebaseAuth

protocol FirebaseAuthManagerProtocol: AnyObject {
    var currentUserId: String? { get }
    var isAuthorized: Bool { get }
    var isVerified: Bool { get }

    func signUp(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void)
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void)
    
}

// MARK: - Реальная реализация через Firebase Auth
final class FirebaseAuthManager: FirebaseAuthManagerProtocol {

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var isAuthorized: Bool {
        Auth.auth().currentUser != nil
    }

    var isVerified: Bool {
        Auth.auth().currentUser?.isEmailVerified ?? false
    }

    // MARK: - Регистрация нового пользователя
    func signUp(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(self.mapFirebaseError(error)))
                    return
                }

                guard let uid = authResult?.user.uid else {
                    completion(.failure(.missingUID))
                    return
                }

                completion(.success(uid))
            }
        }
    }

    // MARK: - Вход существующего пользователя
    func signIn(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(self.mapFirebaseError(error)))
                    return
                }

                guard let uid = authResult?.user.uid else {
                    completion(.failure(.missingUID))
                    return
                }

                completion(.success(uid))
            }
        }
    }

    // MARK: - Маппинг ошибок Firebase → AuthError
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError

        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown
        }

        switch errorCode {
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .wrongPassword:
            return .wrongPassword
        case .userNotFound:
            return .userNotFound
        case .userDisabled:
            return .userDisabled
        case .tooManyRequests:
            return .tooManyRequests
        case .networkError:
            return .networkError
        case .operationNotAllowed:
            return .operationNotAllowed
        case .invalidCredential:
            return .invalidCredential
        default:
            return .unknown
        }
    }

    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        do {
            try Auth.auth().signOut()
//            defaults.removeObject(forKey: Keys.city)
            completion(.success(()))
        } catch {
            completion(.failure(.unknown))
        }
    }
}

// MARK: - Custom Auth Error
enum AuthError: Error, LocalizedError, Equatable {
    // Client-side validation
    case invalidEmailFormat
    case weakPasswordFormat

    // Most common Firebase Auth error codes
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case userDisabled
    case tooManyRequests
    case networkError
    case operationNotAllowed
    case invalidCredential

    // Local/parsing failures
    case missingUID
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmailFormat:
            return "auth_error_invalid_email_format".loc
        case .weakPasswordFormat:
            return "auth_error_weak_password_format".loc
        case .emailAlreadyInUse:
            return "auth_error_email_already_in_use".loc
        case .invalidEmail:
            return "auth_error_invalid_email".loc
        case .weakPassword:
            return "auth_error_weak_password".loc
        case .wrongPassword:
            return "auth_error_wrong_password".loc
        case .userNotFound:
            return "auth_error_user_not_found".loc
        case .userDisabled:
            return "auth_error_user_disabled".loc
        case .tooManyRequests:
            return "auth_error_too_many_requests".loc
        case .networkError:
            return "auth_error_network".loc
        case .operationNotAllowed:
            return "auth_error_operation_not_allowed".loc
        case .invalidCredential:
            return "auth_error_invalid_credential".loc
        case .missingUID:
            return "auth_error_missing_uid".loc
        case .unknown:
            return "auth_error_unknown".loc
        }
    }
}
