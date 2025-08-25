//import Foundation
//import FirebaseAuth
//
//protocol FirebaseManagerProtocol: AnyObject {
//    func sendVerificationCode(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void)
//    func validatePhoneNumber(_ phoneNumber: String) -> Bool
//    func isTestPhoneNumber(_ phoneNumber: String) -> Bool
//}
//
//final class FirebaseManager: FirebaseManagerProtocol {
//    
//    private let userDefaults: UserDefaults
//    private let testPhoneNumbers: [String] = [
//        "+7 999 999-99-99"
//    ]
//    
//    init(userDefaults: UserDefaults = .standard) {
//        self.userDefaults = userDefaults
//        setupTestEnvironment()
//    }
//    
//    // MARK: - Настройка тестового окружения
//    private func setupTestEnvironment() {
//        #if DEBUG
//        // Включаем тестовый режим для Firebase Auth
//        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
//        print("⚠️ Тестовый режим Firebase Auth активирован")
//        #endif
//    }
//    
//    // MARK: - Проверка тестового номера
//    func isTestPhoneNumber(_ phoneNumber: String) -> Bool {
//        let formattedNumber = phoneNumber.formatPhoneNumber()
//        return testPhoneNumbers.contains(formattedNumber)
//    }
//    
//    // MARK: - Валидация номера телефона
//    func validatePhoneNumber(_ phoneNumber: String) -> Bool {
//        let cleanedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//        return cleanedNumber.count >= 10 && cleanedNumber.count <= 15
//    }
//    
//    // MARK: - Отправка кода верификации
//    func sendVerificationCode(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
//        
//        guard !phoneNumber.isEmpty else {
//            completion(.failure(NSError(domain: "FirebaseAuth", code: -1,
//                                      userInfo: [NSLocalizedDescriptionKey: "Номер телефона не может быть пустым"])))
//            return
//        }
//        
//        guard validatePhoneNumber(phoneNumber) else {
//            completion(.failure(NSError(domain: "FirebaseAuth", code: -3,
//                                      userInfo: [NSLocalizedDescriptionKey: "Неверный формат номера телефона"])))
//            return
//        }
//        
//        let formattedPhoneNumber = phoneNumber.formatPhoneNumber()
//        print("📱 Отправка кода на номер: \(formattedPhoneNumber)")
//        
//        // Проверяем тестовый номер
//        if isTestPhoneNumber(formattedPhoneNumber) {
//            print("✅ Используется тестовый номер")
//            handleTestPhoneNumber(formattedPhoneNumber, completion: completion)
//            return
//        }
//        
//        // Для реальных номеров - проверяем биллинг
//        checkBillingStatus { [weak self] hasBilling in
//            guard let self = self else { return }
//            
//            if !hasBilling {
//                completion(.failure(NSError(domain: "FirebaseAuth", code: 17999,
//                                          userInfo: [NSLocalizedDescriptionKey: "Биллинг не настроен. Перейдите в Firebase Console → Billing и настройте платежный аккаунт. Для тестирования используйте номера: +15555550123 до +15555550132"])))
//                return
//            }
//            
//            self.sendRealVerificationCode(phoneNumber: formattedPhoneNumber, completion: completion)
//        }
//    }
//    
//    // MARK: - Обработка тестовых номеров
//    private func handleTestPhoneNumber(_ phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
//        // Для тестовых номеров используем стандартный механизм Firebase
//        DispatchQueue.global(qos: .userInitiated).async {
//            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        completion(.failure(error))
//                        return
//                    }
//                    
//                    guard let verificationID = verificationID else {
//                        completion(.failure(NSError(domain: "FirebaseAuth", code: -2,
//                                                  userInfo: [NSLocalizedDescriptionKey: "Не удалось получить verification ID"])))
//                        return
//                    }
//                    
//                    print("✅ Тестовый код отправлен")
//                    self.userDefaults.set(verificationID, forKey: "authVerificationID")
//                    completion(.success(verificationID))
//                }
//            }
//        }
//    }
//    
//    // MARK: - Отправка реального SMS
//    private func sendRealVerificationCode(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        completion(.failure(self.analyzeError(error)))
//                        return
//                    }
//                    
//                    guard let verificationID = verificationID else {
//                        completion(.failure(NSError(domain: "FirebaseAuth", code: -2,
//                                                  userInfo: [NSLocalizedDescriptionKey: "Не удалось получить verification ID"])))
//                        return
//                    }
//                    
//                    self.userDefaults.set(verificationID, forKey: "authVerificationID")
//                    completion(.success(verificationID))
//                }
//            }
//        }
//    }
//    
//    // MARK: - Проверка статуса биллинга (упрощенная)
//    private func checkBillingStatus(completion: @escaping (Bool) -> Void) {
//        // В реальном приложении здесь можно добавить API вызов для проверки статуса
//        // Для упрощения предполагаем, что биллинг включен после настройки
//        completion(true) // Измените на false для тестирования ошибки
//    }
//
//    // MARK: - Анализ ошибок
//    private func analyzeError(_ error: Error) -> Error {
//        let nsError = error as NSError
//        
//        if nsError.domain == "FIRAuthErrorDomain" && nsError.code == 17999 {
//            return NSError(domain: "FirebaseAuth", code: nsError.code,
//                         userInfo: [NSLocalizedDescriptionKey: "Ошибка биллинга Firebase. Перейдите в Firebase Console → Billing и настройте платежный аккаунт. Для тестирования используйте тестовые номера: +15555550123 до +15555550132"])
//        }
//        
//        return error
//    }
//}
