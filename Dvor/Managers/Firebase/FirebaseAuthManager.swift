import Foundation
import FirebaseAuth

protocol FirebaseAuthManagerProtocol: AnyObject {
    var currentUser: User? { get }
    var isAuthorized: Bool { get }
    var isEmailVerified: Bool { get }

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void)
    func reloadUser(completion: @escaping (Result<Void, Error>) -> Void)
    func signOut() throws
}



final class FirebaseAuthManager: FirebaseAuthManagerProtocol {

    var currentUser: User? { Auth.auth().currentUser }
    var isAuthorized: Bool { currentUser != nil }
    var isEmailVerified: Bool { currentUser?.isEmailVerified ?? false }

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard validateEmail(email) else { completion(.failure(AuthError.invalidEmail)); return }
        guard password.count >= 6 else { completion(.failure(AuthError.weakPassword)); return }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as? NSError,
               error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                completion(.failure(AuthError.emailAlreadyInUse)); return
            }
            error != nil ? completion(.failure(error!)) : completion(.success(result!.user))
        }
    }


    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            error != nil ? completion(.failure(error!)) : completion(.success(result!.user))
        }
    }
    

    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = currentUser else { completion(.failure(AuthError.noUser)); return }
        user.sendEmailVerification { error in
            error != nil ? completion(.failure(error!)) : completion(.success(()))
        }
    }

    func reloadUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = currentUser else { completion(.failure(AuthError.noUser)); return }
        user.reload { error in
            error != nil ? completion(.failure(error!)) : completion(.success(()))
        }
    }

    func signOut() throws { try Auth.auth().signOut() }

    private func validateEmail(_ email: String) -> Bool {
        email.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) != nil
    }
}


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


