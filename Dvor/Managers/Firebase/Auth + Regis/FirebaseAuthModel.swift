
import Foundation

enum AuthStrings {
    static let invalidEmail = "auth.invalid_email".loc
    static let weakPassword = "auth.weak_password".loc
    static let emailAlreadyInUse = "auth.email_already_in_use".loc
    static let noUser = "auth.no_user".loc
}

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case noUser

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return AuthStrings.invalidEmail
        case .weakPassword:
            return AuthStrings.weakPassword
        case .emailAlreadyInUse:
            return AuthStrings.emailAlreadyInUse
        case .noUser:
            return AuthStrings.noUser
        }
    }
}
