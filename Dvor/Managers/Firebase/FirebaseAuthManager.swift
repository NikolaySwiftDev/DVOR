import Foundation
import FirebaseAuth

protocol FirebaseAuthManagerProtocol: AnyObject {
//    var currentUser: User? { get } для firebase
    var currentUserId: String? { get }
    var isAuthorized: Bool { get }
    var isEmailVerified: Bool { get }

//    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) для firebase
    func signUp()
//    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) для firebase
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)

    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void)
    func reloadUser(completion: @escaping (Result<Void, Error>) -> Void)
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void)
}

//final class FirebaseAuthManager: FirebaseAuthManagerProtocol {
//
//    var currentUser: User? { Auth.auth().currentUser }
//    var isAuthorized: Bool { currentUser != nil }
//    var isEmailVerified: Bool { currentUser?.isEmailVerified ?? false }
//
//    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
//        guard validateEmail(email) else { completion(.failure(AuthError.invalidEmail)); return }
//        guard password.count >= 6 else { completion(.failure(AuthError.weakPassword)); return }
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error as? NSError,
//               error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
//                completion(.failure(AuthError.emailAlreadyInUse)); return
//            }
//            error != nil ? completion(.failure(error!)) : completion(.success(result!.user))
//        }
//    }
//
//    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            error != nil ? completion(.failure(error!)) : completion(.success(result!.user))
//        }
//    }
//    
//    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let user = currentUser else { completion(.failure(AuthError.noUser)); return }
//        user.sendEmailVerification { error in
//            error != nil ? completion(.failure(error!)) : completion(.success(()))
//        }
//    }
//
//    func reloadUser(completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let user = currentUser else { completion(.failure(AuthError.noUser)); return }
//        user.reload { error in
//            error != nil ? completion(.failure(error!)) : completion(.success(()))
//        }
//    }
//
//    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
//        do {
//            try Auth.auth().signOut()
//            completion(.success(()))
//        } catch {
//            completion(.failure(error))
//        }
//    }
//
//    private func validateEmail(_ email: String) -> Bool {
//        email.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) != nil
//    }
//}

enum AuthError: LocalizedError {
    case invalidEmail, weakPassword, emailAlreadyInUse, noUser

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Некорректный email"
        case .weakPassword: return "Пароль должен быть не короче 6 символов"
        case .emailAlreadyInUse: return "Почта уже зарегистрирована"
        case .noUser: return "Пользователь не найден"
        }
    }
}


final class MockFirebaseAuthManager: FirebaseAuthManagerProtocol {

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let isAuthorized    = "mock_auth_isAuthorized"
        static let userId          = "mock_auth_userId"
        
    }

    private let defaults = UserDefaults.standard

    // MARK: - Protocol Properties

    /// FirebaseAuth.User нельзя создать вручную, поэтому всегда nil в mock-е.
    /// Везде, где нужен currentUser, используй isAuthorized / isEmailVerified.
    var currentUserId: String? {
        guard isAuthorized else { return nil }
        // Генерируем UUID один раз при первой авторизации и сохраняем
        if let saved = defaults.string(forKey: Keys.userId) { return saved }
        let newId = UUID().uuidString
        defaults.set(newId, forKey: Keys.userId)
        return newId
    }

    var isAuthorized: Bool {
        get { defaults.bool(forKey: Keys.isAuthorized) }
        set { defaults.set(newValue, forKey: Keys.isAuthorized) }
    }

    var isEmailVerified: Bool {
        true
    }

    // MARK: - Auth Methods

    func signUp() {
        let newUserId = UUID().uuidString
        defaults.set(newUserId, forKey: Keys.userId)
        isAuthorized    = true

    }

    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId    = defaults.string(forKey: Keys.userId) else { return }
        isAuthorized = true
        completion(.success(userId))
    }

    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        guard isAuthorized else {
            return completion(.failure(AuthError.noUser))
        }
        completion(.success(()))
    }

    func reloadUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard isAuthorized else {
            return completion(.failure(AuthError.noUser))
        }
        completion(.success(()))
    }

    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        isAuthorized    = false
        defaults.removeObject(forKey: Keys.userId)
        completion(.success(()))
    }

    // MARK: - Private

    private func validateEmail(_ email: String) -> Bool {
        email.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) != nil
    }
}

// MARK: - AuthError extension

extension AuthError {
    /// Сигнал успеха для signUp/signIn, где нельзя вернуть реальный FirebaseAuth.User.
    /// В ViewModel обрабатывай его как успех:
    ///   if case .failure(AuthError.mockSuccess) = result { /* treat as success */ }
    static var mockSuccess: AuthError { .noUser }   // переиспользуем кейс или добавь новый ниже
}
