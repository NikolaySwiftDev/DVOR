
import Foundation

enum SettingsRow {
    case blockedUsers
    case privacy
    case terms
    case signOut
    case deleteAccount

    var title: String {
        switch self {
        case .blockedUsers: return ProfileViewConstants.blockedUsers
        case .privacy:      return ProfileViewConstants.privacy
        case .terms:        return ProfileViewConstants.terms
        case .signOut:      return ProfileViewConstants.signOutButton
        case .deleteAccount: return ProfileViewConstants.deleteAccountButton
        }
    }

    var hasDisclosure: Bool {
        switch self {
        case .blockedUsers, .privacy, .terms: return true
        case .signOut, .deleteAccount: return false
        }
    }
}
