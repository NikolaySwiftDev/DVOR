
import Foundation
import UIKit

protocol RegistProtocol: AnyObject {
    func showError(_ message: String)
    func showSuccess()
    func showLoading()
    func hideLoading()
    
    func updateAvatarImage(_ image: UIImage)
    func updateTFText(_ code: String)
}

protocol RegistPresenterProtocol: AnyObject {
    func popVC()

    func makeCodeRequest(with code: String)
    
    func repeatCodeRequest(with code: String)
    func makePhoneRequest(with phone: String)
    
    func pickPhoto()
    
    func appendNotification()
    
    func completeRegistration(model: RegistrationData)
    
    func pushViewController(_ vc: UIViewController)
    func setViewController(_ vc: UIViewController)
    

    init(router: RouterMainProtocol,
//         firebase: FirebaseManagerProtocol,
         network: FirebaseDataManager,
         userDefaults: UserDefaultsProtocol,
         photoManager: PhotoManagerProtocol,
         notifManager: NotificationManagerProtocol)
}

final class RegistPresenter: RegistPresenterProtocol {


    weak var view: RegistProtocol?
    let userDefaults: UserDefaultsProtocol
    let router: RouterMainProtocol?
//    let firebase: FirebaseManagerProtocol?
    let network: FirebaseDataManager
    let photoManager: PhotoManagerProtocol
    let notifManager: NotificationManagerProtocol
    
    private let mock = true
    private var code = "12345"

    required init(router: RouterMainProtocol,
//                  firebase: FirebaseManagerProtocol,
                  network: FirebaseDataManager,
                  userDefaults: UserDefaultsProtocol,
                  photoManager: PhotoManagerProtocol,
                  notifManager: NotificationManagerProtocol) {
        self.router = router
//        self.firebase = firebase
        self.network = network
        self.userDefaults = userDefaults
        self.photoManager = photoManager
        self.notifManager = notifManager
    }
    
    func popVC() {
        router?.popVC()
    }
    
    func makeCodeRequest(with phone: String) {
        if mock {
            print("Request with phone \(phone)")
            view?.showLoading()
            view?.updateTFText(code)
        } else {
//            firebase?.sendVerificationCode(phoneNumber: phone, completion: { [weak self] result in
//                 guard let self = self else { return }
//                switch result {
//                case .success(let code):
//                    self.code = code
//                    print("CODE -----", code)
//                case .failure(let error):
//                    router?.showErrorAlerWithTitle(error.localizedDescription)
//                }
//            })
        }
    }
    
    func repeatCodeRequest(with phone: String) {
        if mock {
            router?.showErrorAlerWithTitle("Запрос отправлен")
            view?.showLoading()
            print("Request with phone \(phone)")
        } else {
//            router?.showErrorAlerWithTitle("Запрос отправлен")
//            view?.showLoading()
//            firebase?.sendVerificationCode(phoneNumber: phone, completion: { [weak self] result in
////                guard let self = self else { return }
//                switch result {
//                case .success(let code):
//                    print("CODE -----", code)
//                case .failure(let error):
//                    print("Error -----", error.localizedDescription)
//                }
//            })
        }
    }
    
    func makePhoneRequest(with code: String) {
        if code == self.code {
            view?.showSuccess()
        } else {
            let error = "Неверный код"
            print(self.code)
            router?.showErrorAlerWithTitle(error)
            view?.showError(error)
        }
    }
    
    func pickPhoto() {
        view?.showLoading()
        photoManager.pickPhoto(from: router) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.view?.updateAvatarImage(image)
                self.view?.showSuccess()
                self.view?.hideLoading()
                
            case .failure(let error):
                self.view?.hideLoading()
                if error != .cancelled {
                    let errorMessage = error.errorDescription ?? "Ошибка выбора фото"
                    self.view?.showError(errorMessage)
                    self.router?.showErrorAlerWithTitle(errorMessage)
                }
            }
        }
    }
    
    func appendNotification() {
        view?.showLoading()
        notifManager.requestAuthorization { [weak self] granted, error  in
            guard let self = self else { return }
            if let error = error {
                view?.showError(error.localizedDescription)
            } else {
                if granted {
                    view?.showSuccess()
                } else {
                    view?.showError("No notif")
                }
            }
            view?.hideLoading()
        }
    }

    func completeRegistration(model: RegistrationData) {        
        let data = UserModel(image: model.image,
                             name: model.name,
                             surname: model.surname,
                             dateBirthday: model.dateBD,
                             mobile: model.phone,
                             experience: model.experience,
                             city: model.city,
                             position: model.position)
        
        network.writeUser(model: data, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                userDefaults.saveUserInfo(model: data)
                router?.pushTabBarVC()
            case .failure(let failure):
                router?.showAuthErrorAlert(handelr: { [weak self] in
                    guard let self = self else { return }
                    self.router?.pushTabBarVC()
                })
            }
        })
    }
    
    func pushViewController(_ vc: UIViewController) {
        router?.pushVC(vc)
    }
    
    func setViewController(_ vc: UIViewController) {
        router?.setVC(vc)
    }
    

    deinit {
        print("Deinit Registr Presenter")
    }
}
