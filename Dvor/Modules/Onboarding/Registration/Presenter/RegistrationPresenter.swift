
import Foundation
import UIKit

protocol RegistProtocol: AnyObject {
    func showError(_ message: String)
    func showSuccess()
    func showLoading()
    func hideLoading()
    
    func updateAvatarImage(_ image: UIImage)
    func showInfoInput()
}

protocol RegistPresenterProtocol: AnyObject {
    func popVC()

    func signUp(email: String, password: String)
    func checkEmailVerification()
    func resendVerificationEmail()
        
    func pickPhoto()
    
    func appendNotification()
    
    func completeRegistration(model: RegistrationData)
    
    func pushViewController(_ vc: UIViewController)
    func setViewController(_ vc: UIViewController)
    

    init(router: RouterMainProtocol,
         firebase: FirebaseAuthManagerProtocol,
         network: FirebaseDataManager,
         photoManager: PhotoManagerProtocol,
         notifManager: NotificationManagerProtocol)
}

final class RegistPresenter: RegistPresenterProtocol {

    weak var view: RegistProtocol?
    let router: RouterMainProtocol?
    let firebase: FirebaseAuthManagerProtocol
    let network: FirebaseDataManager
    let photoManager: PhotoManagerProtocol
    let notifManager: NotificationManagerProtocol
    
    required init(router: RouterMainProtocol,
                  firebase: FirebaseAuthManagerProtocol,
                  network: FirebaseDataManager,
                  photoManager: PhotoManagerProtocol,
                  notifManager: NotificationManagerProtocol) {
        self.router = router
        self.firebase = firebase
        self.network = network
        self.photoManager = photoManager
        self.notifManager = notifManager
    }
    
    func popVC() {
        router?.popVC()
    }
    
    func signUp(email: String, password: String) {
        view?.showLoading()
        firebase.signUp(email: email, password: password) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                // Новый пользователь: отправляем письмо с подтверждением
                self.firebase.sendEmailVerification { [weak self] sendResult in
                    guard let self = self else { return }
                    switch sendResult {
                    case .success:
                        self.view?.showSuccess()
                    case .failure(let error):
                        self.view?.showError(error.localizedDescription)
                        self.router?.showAlertWithTitle(error.localizedDescription)
                    }
                }
            case .failure(let error):
                // Пытаемся войти
                self.firebase.signIn(email: email, password: password) { [weak self] signInResult in
                    guard let self = self else { return }
                    switch signInResult {
                    case .success:
                        // Пользователь уже существует: проверяем, верифицирован ли email
                        self.firebase.reloadUser { [weak self] reloadResult in
                            guard let self = self else { return }
                            switch reloadResult {
                            case .success:
                                if self.firebase.isEmailVerified {
                                    // Почта уже подтверждена — просто продолжаем flow без повторной отправки письма
                                    
                                    self.view?.showInfoInput()
                                } else {
                                    // Почта не подтверждена — отправляем письмо и продолжаем как обычно
                                    self.firebase.sendEmailVerification { [weak self] sendResult in
                                        guard let self = self else { return }
                                        switch sendResult {
                                        case .success:
                                            self.view?.showSuccess()
                                        case .failure(let error):
                                            self.view?.showError(error.localizedDescription)
                                            self.router?.showAlertWithTitle(error.localizedDescription)
                                        }
                                    }
                                }
                            case .failure(let reloadError):
                                self.view?.showError(reloadError.localizedDescription)
                                self.router?.showAlertWithTitle(reloadError.localizedDescription)
                            }
                        }
                    case .failure(let signInError):
                        self.view?.showError(signInError.localizedDescription)
                        self.router?.showAlertWithTitle(signInError.localizedDescription)
                    }
                }
            }
        }
    }

    func checkEmailVerification() {
        view?.showLoading()
        firebase.reloadUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if self.firebase.isEmailVerified {
                    self.view?.showSuccess()
                } else {
                    self.router?.showAlertWithTitle("Почта ещё не подтверждена")
                    self.view?.showError("Почта ещё не подтверждена")
                }
            case .failure(let error):
                self.view?.showError(error.localizedDescription)
            }
        }
    }

    
    func resendVerificationEmail() {
        view?.showLoading()
        firebase.sendEmailVerification { [weak self] result in
            guard let self = self else { return }
            self.view?.hideLoading()
            switch result {
            case .success:
                self.router?.showAlertWithTitle("Письмо отправлено повторно")
            case .failure(let error):
                self.view?.showError(error.localizedDescription)
            }
        }
    }

    
    func pickPhoto() {
        view?.showLoading()
        photoManager.pickPhoto(from: router, maxSize: SizeLimits.mb3) { [weak self] result in
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
                    self.router?.showAlertWithTitle(errorMessage)
                }
                
                if error == .sizeExceeded(maxSize: SizeLimits.mb3) {
                    let errorMessage = error.errorDescription ?? "Ошибка выбора фото"
                    self.view?.showError(errorMessage)
                    self.router?.showAlertWithTitle(errorMessage)
                    
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
        // Используем ID текущего пользователя из Firebase Auth, а не сгенерированный UUID
        guard let userId = firebase.currentUser?.uid else {
            router?.showAlertWithTitle("Ошибка: пользователь не авторизован")
            return
        }
        
        let data = UserModel(id: userId,
                             image: model.image,
                             name: model.name,
                             surname: model.surname,
                             dateBirthday: model.dateBD,
                             mobile: model.email,
                             experience: model.experience,
                             city: model.city,
                             position: model.position)
        
        network.writeUser(model: data, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                router?.pushTabBarVC()
            case .failure(let error):
                router?.showAlertConfigur(title: "Ошибка записи",
                                          message: error.localizedDescription,
                                          titleActionButton: "Продолжить",
                                          handelr:  { [weak self] in
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
