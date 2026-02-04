import Foundation

//final class UserDefaultsManager {
//    
//    static let shared = UserDefaultsManager()
//
//    private let userDefaults = UserDefaults.standard
//    private let encoder = JSONEncoder()
//    private let decoder = JSONDecoder()
//    
//    private let userInfoAuth = "userInfoAuth"
//    private let userInfoModel = "userInfoModel"
//    private let idKey = "id"
//    
//    private init() {}
    
    //MARK: - Запись данных
    
    // Авторизация
//    func setAuthorizationStatus(_ isAuthorized: Bool) {
//        userDefaults.set(isAuthorized, forKey: userInfoAuth)
//    }
//    
//    // Пользователь id
//    func saveUser(model: UserModel) {
//        let id = model.id
//        userDefaults.set(id, forKey: idKey)
//        setAuthorizationStatus(true)
//        print("Данные пользователя успешно сохранены")
//    }
//    
//    //MARK: - Удаление данных
//    func deleteAuthStatus() {
//        userDefaults.removeObject(forKey: userInfoAuth)
//        userDefaults.removeObject(forKey: userInfoModel)
//        userDefaults.removeObject(forKey: idKey)
//    }
//        
//    //MARK: - Чтение данных
//    
//    //статус авторизации
//    func getAuthorizationStatus() -> Bool {
//        return userDefaults.bool(forKey: userInfoAuth)
//    }
//    
//    // id Пользователя
//    func getIDUser() -> String? {
//        return userDefaults.string(forKey: idKey)
//    }
//
//    deinit {
//        print("Deinit UserDefaultsManager")
//    }

//}

