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
        
    func pickPhoto()
    
    func appendNotification()
    
    func completeRegistration(model: RegistrationData)
    
    func pushViewController(_ vc: UIViewController)
    func setViewController(_ vc: UIViewController)
    
    func requestCurrentCity(completion: @escaping (CityModel?) -> Void)
    
    func updateCity(city: CityModel)
    func updateAvatar(avatar: UIImage)
    func updateNickname(nickname: String)
    

    init(router: RouterMainProtocol,
         firebase: FirebaseAuthManagerProtocol,
         network: FirebaseDataManagerProtocol,
         photoManager: PhotoManagerProtocol?,
         notifManager: NotificationManagerProtocol?,
         locationManager: LocationManagerProtocol?,
         appCoordinator: AppCoordinatorProtocol?
    )
}

final class RegistPresenter: RegistPresenterProtocol {

    weak var view: RegistProtocol?
    let router: RouterMainProtocol?
    let firebase: FirebaseAuthManagerProtocol
    let network: FirebaseDataManagerProtocol
    let photoManager: PhotoManagerProtocol?
    let notifManager: NotificationManagerProtocol?
    let locationManager: LocationManagerProtocol?
    let appCoordinator: AppCoordinatorProtocol?
    
    required init(router: RouterMainProtocol,
                  firebase: FirebaseAuthManagerProtocol,
                  network: FirebaseDataManagerProtocol,
                  photoManager: PhotoManagerProtocol? = nil,
                  notifManager: NotificationManagerProtocol? = nil,
                  locationManager: LocationManagerProtocol? = nil,
                  appCoordinator: AppCoordinatorProtocol? = nil
    ) {
        self.router = router
        self.firebase = firebase
        self.network = network
        self.photoManager = photoManager
        self.notifManager = notifManager
        self.locationManager = locationManager
        self.appCoordinator = appCoordinator
    }
    
    func popVC() {
        router?.popVC()
    }
    
    func pickPhoto() {
        guard let photoManager else {
            view?.showError(RegistPresenterStrings.photoPickerError)
            return
        }
        
        view?.showLoading()
        photoManager.pickPhoto(from: router, maxSize: SizeLimits.mb8) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.view?.updateAvatarImage(image)
                self.view?.showSuccess()
                self.view?.hideLoading()

            case .failure(let error):
                self.view?.hideLoading()
                if error != .cancelled {
                    let errorMessage = error.errorDescription ?? RegistPresenterStrings.photoPickerError
                    self.view?.showError(errorMessage)
                    self.router?.showAlertWithTitle(errorMessage)
                }
                
                if error == .sizeExceeded(maxSize: SizeLimits.mb8) {
                    let errorMessage = error.errorDescription ?? RegistPresenterStrings.photoPickerError
                    self.view?.showError(errorMessage)
                    self.router?.showAlertWithTitle(errorMessage)
                    
                }
            }
        }
    }
    
    func appendNotification() {
        guard let notifManager else { return }
        
        view?.showLoading()
        notifManager.requestAuthorization { [weak self] granted, error  in
            guard let self = self else { return }
            if let error = error {
                view?.showError(error.localizedDescription)
            } else {
                if granted {
                    view?.showSuccess()
                } else {
                    view?.showError(RegistPresenterStrings.notificationsDisabled)
                }
            }
            view?.hideLoading()
        }
    }

    func completeRegistration(model: RegistrationData) {

        let city = CityModel(
            name: model.city,
            countryCode: model.countryCode ?? "",
            administrativeArea: model.administrativeArea,
            latitude: model.latitude ?? 0,
            longitude: model.longitude ?? 0
        )

        firebase.signUp(city: city)

        guard let userId = firebase.currentUserId else {
            router?.showAlertWithTitle(RegistPresenterStrings.unauthorizedUser)
            return
        }
        
        let data = UserModel(id: userId,
                             image: model.image,
                             name: model.name,
                             experience: model.experience,
                             city: model.city,
                             countryCode: model.countryCode ?? "",
                             administrativeArea: model.administrativeArea,
                             latitude: model.latitude ?? 0,
                             longitude: model.longitude ?? 0,
                             position: model.position
        )
        
        network.writeUser(model: data, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                appCoordinator?.showHome()
            case .failure(let error):
                router?.showAlertWithTitle(error.localizedDescription)
            }
        })
    }
    
    func pushViewController(_ vc: UIViewController) {
        router?.pushVC(vc)
    }
    
    func setViewController(_ vc: UIViewController) {
        router?.setVC(vc)
    }
    
    // MARK: - Location -> City
    func requestCurrentCity(completion: @escaping (CityModel?) -> Void) {
        guard let locationManager else {
            completion(nil)
            return
        }
        
        locationManager.requestCurrentCity { [weak self] city, error  in
            guard let self = self else { return }
            if let error {
                router?.showAlertWithTitle(error.localizedDescription)
            }
            completion(city)
        }
    }
    
    func updateCity(city: CityModel) {
        guard let userId = firebase.currentUserId else {
            router?.showAlertWithTitle(RegistPresenterStrings.unauthorizedUser)
            return
        }

        let fields: [String: Any] = [
            "city": city.name,
            "countryCode": city.countryCode,
            "administrativeArea": city.administrativeArea as Any,
            "latitude": city.latitude,
            "longitude": city.longitude
        ]

        view?.showLoading()
        network.updateUser(userId: userId, fields: fields) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let city = CityModel(name: city.name,
                                     countryCode: city.countryCode,
                                     administrativeArea: city.administrativeArea,
                                     latitude: city.latitude,
                                     longitude: city.longitude)
                firebase.updateCity(city: city)
                router?.showAlertWithCompletion(RegistPresenterStrings.successUpdate,
                                                completion: {  [weak self] in
                    guard let self = self else { return }
                    self.router?.popVC()
                })
            case .failure(let error):
                self.router?.showAlertWithTitle(error.localizedDescription)
            }
        }
    }
    
    func updateAvatar(avatar: UIImage) {
        guard let userId = firebase.currentUserId else {
            router?.showAlertWithTitle(RegistPresenterStrings.unauthorizedUser)
            return
        }

        guard let imageData = avatar.jpegData(compressionQuality: 0.3) else {
            view?.showError(RegistPresenterStrings.photoPickerError)
            return
        }

        let base64String = imageData.base64EncodedString()
        let fields: [String: Any] = ["image": base64String]

        network.updateUser(userId: userId, fields: fields) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideLoading()
            switch result {
            case .success:
                self.view?.updateAvatarImage(avatar)
                self.view?.showSuccess()
                router?.showAlertWithCompletion(RegistPresenterStrings.successUpdate,
                                                completion: {  [weak self] in
                    guard let self = self else { return }
                    self.router?.popVC()
                })
            case .failure(let error):
                self.router?.showAlertWithTitle(error.localizedDescription)
            }
        }
    }

    func updateNickname(nickname: String) {
        guard let userId = firebase.currentUserId else {
            router?.showAlertWithTitle(RegistPresenterStrings.unauthorizedUser)
            return
        }

        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            view?.showError(RegistPresenterStrings.emptyNicknameError)
            return
        }
        
        let fields: [String: Any] = ["name": trimmed]
        network.updateUser(userId: userId, fields: fields) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideLoading()
            switch result {
            case .success:
                router?.showAlertWithCompletion(RegistPresenterStrings.successUpdate,
                                                completion: {  [weak self] in
                    guard let self = self else { return }
                    self.router?.popVC()
                })
                
            case .failure(let error):
                self.router?.showAlertWithTitle(error.localizedDescription)
            }
        }
    }
    
    deinit {
        print("Deinit RegistPresenter")
    }
}

fileprivate struct RegistPresenterStrings {
    static let photoPickerError = "registration.photo_picker_error".loc
    static let notificationsDisabled = "registration.notifications_disabled".loc
    static let emptyNicknameError = "registration.empty_nickname_error".loc
    static let successUpdate = "registration.success_update".loc

    static let unauthorizedUser = "registration.unauthorized_user".loc
    static let writeErrorTitle = "registration.write_error_title".loc
    static let continueButton = "common.continue".loc
    static let yes = "Yes".loc
}
