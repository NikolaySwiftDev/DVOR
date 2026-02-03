
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
//         userDefaults: UserDefaultsProtocol,
         photoManager: PhotoManagerProtocol,
         notifManager: NotificationManagerProtocol)
}

final class RegistPresenter: RegistPresenterProtocol {


    weak var view: RegistProtocol?
//    let userDefaults: UserDefaultsProtocol
    let router: RouterMainProtocol?
    let firebase: FirebaseAuthManagerProtocol
    let network: FirebaseDataManager
    let photoManager: PhotoManagerProtocol
    let notifManager: NotificationManagerProtocol
    
    required init(router: RouterMainProtocol,
                  firebase: FirebaseAuthManagerProtocol,
                  network: FirebaseDataManager,
//                  userDefaults: UserDefaultsProtocol,
                  photoManager: PhotoManagerProtocol,
                  notifManager: NotificationManagerProtocol) {
        self.router = router
        self.firebase = firebase
        self.network = network
//        self.userDefaults = userDefaults
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
                view?.hideLoading()
                view?.showSuccess()
            case .failure(let error):
                view?.hideLoading()
                view?.showError(error.localizedDescription)
                router?.showAlertWithTitle(error.localizedDescription)

            }
        }
    }

    
    func checkEmailVerification() {
//        Task {
//            do {
//                try await firebase.reloadUser()
//                if firebase.isEmailVerified {
//                    router?.showAlertWithTitle("Почта подтверждена", )
//                } else {
//                    view?.showError("Почта ещё не подтверждена")
//                }
//            } catch {
//                view?.showError(error.localizedDescription)
//            }
//        }
    }

    
    func resendVerificationEmail() {
//        Task {
//            do {
//                try await firebase.sendEmailVerification()
//                router?.showAlertWithTitle("Письмо отправлено повторно")
//            } catch {
//                view?.showError(error.localizedDescription)
//            }
//        }
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
        let data = UserModel(image: model.image,
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
//                userDefaults.saveUser(model: data)
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
