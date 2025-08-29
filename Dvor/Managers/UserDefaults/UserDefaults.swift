
import Foundation

protocol UserDefaultsProtocol: AnyObject {
    func setAuthorizationStatus(_ isAuthorized: Bool)
    func saveUser(model: UserModel)
    func getAuthorizationStatus() -> Bool
    func getIDUser() -> String? 
//    func loadUserInfo(completion: @escaping (Result<UserModel, Error>) -> Void)
    func deleteAuthStatus()
}

final class UserDefaultsManager: UserDefaultsProtocol {

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let userInfoAuth = "userInfoAuth"
    private let userInfoModel = "userInfoModel"
    private let idKey = "id"
    
    
    //MARK: - Запись данных
    
    // Авторизация
    func setAuthorizationStatus(_ isAuthorized: Bool) {
        userDefaults.set(isAuthorized, forKey: userInfoAuth)
    }
    
    // Пользователь id
    func saveUser(model: UserModel) {
        let id = model.id
        userDefaults.set(id, forKey: idKey)
        setAuthorizationStatus(true)
        print("Данные пользователя успешно сохранены")
    }
    
    //MARK: - Удаление данных
    func deleteAuthStatus() {
        userDefaults.removeObject(forKey: userInfoAuth)
        userDefaults.removeObject(forKey: userInfoModel)
        userDefaults.removeObject(forKey: idKey)
    }
        
    //MARK: - Чтение данных
    
    //статус авторизации
    func getAuthorizationStatus() -> Bool {
        return userDefaults.bool(forKey: userInfoAuth)
    }
    
    // id Пользователя
    func getIDUser() -> String? {
        return userDefaults.string(forKey: idKey)
    }
    
    // Модель пользователя
//    func loadUserInfo(completion: @escaping (Result<UserModel, Error>) -> Void) {
//        guard let data = UserDefaults.standard.data(forKey: userInfoModel) else {
//            let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Данные пользователя не найдены"])
//            completion(.failure(error))
//            return
//        }
//        
//        do {
//            let decoder = JSONDecoder()
//            let user = try decoder.decode(UserModel.self, from: data)
//            completion(.success(user))
//        } catch {
//            print("Ошибка при декодировании пользователя: \(error.localizedDescription)")
//            completion(.failure(error))
//        }
//    }

}
