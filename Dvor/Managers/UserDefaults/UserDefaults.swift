
import Foundation

protocol UserDefaultsProtocol: AnyObject {
    func setAuthorizationStatus(_ isAuthorized: Bool)
    func saveUserInfo(model: RegistrationData)
    func getAuthorizationStatus() -> Bool
    func loadUserInfo(completion: @escaping (Result<UserModel, Error>) -> Void)
    func deleteAuthStatus()
}

final class UserDefaultsManager: UserDefaultsProtocol {

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let userInfoAuth = "userInfoAuth"
    private let userInfoModel = "userInfoPassword"
    
    func setAuthorizationStatus(_ isAuthorized: Bool) {
        userDefaults.set(isAuthorized, forKey: userInfoAuth)
    }
    
    func deleteAuthStatus() {
        userDefaults.removeObject(forKey: userInfoAuth)
        userDefaults.removeObject(forKey: userInfoModel)
    }
    
    func getAuthorizationStatus() -> Bool {
        return userDefaults.bool(forKey: userInfoAuth)
    }
    
    func saveUserInfo(model: RegistrationData) {
        do {
            let data = try encoder.encode(model)

            userDefaults.set(data, forKey: userInfoModel)
            userDefaults.synchronize()
            
            setAuthorizationStatus(true)
            print(userInfoModel)
            print("Данные пользователя успешно сохранены")
        } catch {
            print("Ошибка при сохранении пользователя: \(error.localizedDescription)")
        }
    }
    
    func loadUserInfo(completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard let data = UserDefaults.standard.data(forKey: userInfoModel) else {
            let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Данные пользователя не найдены"])
            completion(.failure(error))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(UserModel.self, from: data)
            completion(.success(user))
        } catch {
            print("Ошибка при декодировании пользователя: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
