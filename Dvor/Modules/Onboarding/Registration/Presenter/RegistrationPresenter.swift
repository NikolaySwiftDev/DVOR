
import Foundation
import UIKit

protocol RegistProtocol: AnyObject {
    func showError(_ message: String)
    func showSuccess()
    func showLoading()
    func hideLoading()
    
    func updateAvatarImage(_ image: UIImage)
}

protocol RegistPresenterProtocol: AnyObject {
    func popVC()

    func makeCodeRequest(with code: String)
    
    func repeatCodeRequest(with code: String)
    func makePhoneRequest(with phone: String)
    
    func pickPhoto()
    
    func appendNotification()
    
    func completeRegistration(model: RegistrationData)
    

    init(router: RouterMainProtocol, userDefaults: UserDefaultsProtocol, photoManager: PhotoManagerProtocol, notifManager: NotificationManagerProtocol)
}

final class RegistPresenter: RegistPresenterProtocol {

    weak var view: RegistProtocol?
    let userDefaults: UserDefaultsProtocol
    let router: RouterMainProtocol?
    let photoManager: PhotoManagerProtocol
    let notifManager: NotificationManagerProtocol

    private var email: String = ""
    private var password: String = ""
    private var firstName: String = ""
    private var lastName: String = ""
    private let date: Date = Date()
    private let position: String = ""
    private let club: String = ""
    private let gender: String = ""
    private let mobile: String = ""

    required init(router: RouterMainProtocol,
                  userDefaults: UserDefaultsProtocol,
                  photoManager: PhotoManagerProtocol,
                  notifManager: NotificationManagerProtocol) {
        self.router = router
        self.userDefaults = userDefaults
        self.photoManager = photoManager
        self.notifManager = notifManager
    }
    
    func popVC() {
        router?.popVC()
    }
    
    func makeCodeRequest(with phone: String) {
        print("Request with phone \(phone)")
        view?.showLoading()
    }
    
    func repeatCodeRequest(with phone: String) {
        router?.showErrorAlerWithTitle("Запрос отправлен")
        view?.showLoading()
        print("Request with phone \(phone)")
    }
    
    func makePhoneRequest(with code: String) {
        if code == "12345" {
            view?.showSuccess()
        } else {
            let error = "Неверный код"
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
        print(model)
        userDefaults.saveUserInfo(model: model)
        router?.pushTabBarVC()
    }
    
    deinit {
        print("Deinit Registr Presenter")
    }
}
