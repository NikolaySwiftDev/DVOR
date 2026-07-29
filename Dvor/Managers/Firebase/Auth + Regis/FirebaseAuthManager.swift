import Foundation
import FirebaseAuth

protocol FirebaseAuthManagerProtocol: AnyObject {
    var currentUserId: String? { get }
    var currentCity: CityModel? { get }
    var isAuthorized: Bool { get }
    var isVerified: Bool { get }

    func signUp(city: CityModel)
    func signIn( completion: @escaping (String) -> Void)
    func signOut(completion: @escaping () -> Void)
}

final class MockFirebaseAuthManager: FirebaseAuthManagerProtocol {
    
    private enum Keys {
        static let isAuthorized = "mock_auth_isAuthorized"
        static let userId       = "mock_auth_userId"
        static let city         = "mock_auth_city"
    }

    private let defaults = UserDefaults.standard

    var currentUserId: String? {
        guard isAuthorized else { return nil }
        if let saved = defaults.string(forKey: Keys.userId) { return saved }
        let newId = UUID().uuidString
        defaults.set(newId, forKey: Keys.userId)
        return newId
    }

    var currentCity: CityModel? {
        guard isAuthorized,
              let data = defaults.data(forKey: Keys.city) else { return nil }
        return try? JSONDecoder().decode(CityModel.self, from: data)
    }

    var isAuthorized: Bool {
        get { defaults.bool(forKey: Keys.isAuthorized) }
        set { defaults.set(newValue, forKey: Keys.isAuthorized) }
    }

    var isVerified: Bool { true }

    // MARK: - Auth Methods

    func signUp(city: CityModel) {
        let newUserId = UUID().uuidString
        defaults.set(newUserId, forKey: Keys.userId)

        if let data = try? JSONEncoder().encode(city) {
            defaults.set(data, forKey: Keys.city)
        }

        isAuthorized = true
    }

    func signIn(completion: @escaping (String) -> Void) {
        guard let userId = defaults.string(forKey: Keys.userId) else { return }
        isAuthorized = true
        completion(userId)
    }

    func signOut(completion: @escaping () -> Void) {
        isAuthorized = false
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.city)
        completion()
    }
}
