import UIKit

protocol Coordinator: AnyObject {
    init(presenter: RegistPresenterProtocol?)
    func start()
}

protocol RegistrationCoordinatorProtocol: Coordinator {
    func showPhoneInput()
    func showPhoneConfirmation(email: String)
    func showInfoInput()
    func showUserDataInput()
    func createAvatar()
    func showSuccess()
}

final class RegistrationCoordinator: RegistrationCoordinatorProtocol {
    
    // MARK: - Properties
    weak var presenter: RegistPresenterProtocol?
    var onRegistrationComplete: (() -> Void)?
    
    private var registrationData = RegistrationData()
    
    // MARK: - Initialization
    init(presenter: RegistPresenterProtocol?) {
        self.presenter = presenter
    }
    
    // MARK: - Start
    func start() {
//        showPhoneInput()
        showInfoInput()
    }
    
    // MARK: - Flow Methods
    func showPhoneInput() {
        let vc = EnterEmailViewController(presenter: presenter)
        
        vc.setInfoForNavigationView(model: .email)
        vc.configureEnadle(false)
        vc.onNext = { [weak self] email in
            self?.registrationData.email = email
            self?.showPhoneConfirmation(email: email)
        }
        
        vc.pushCreateInfo = { [weak self] in
            self?.showInfoInput()
        }
        if let registPresenter = presenter as? RegistPresenter {
            registPresenter.view = vc
        }
        presenter?.pushViewController(vc)
    }
    
    func showPhoneConfirmation(email: String) {
        let vc = EmailConfirmViewController(presenter: presenter)
        vc.setTitleNumberText(with: email)
        vc.configureEnadle(false)
        vc.onNext = { [weak self] in
            self?.showInfoInput()
        }
        if let registPresenter = presenter as? RegistPresenter {
            registPresenter.view = vc
        }
        presenter?.pushViewController(vc)
    }
    
    func showInfoInput() {
        let vc = InfoInputViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .info)
        vc.configureEnadle(false)
//        vc.hideBackButton(true)
        vc.onNext = { [weak self] name, surname, dateBD in
            self?.registrationData.name = name
            self?.registrationData.surname = surname
            self?.registrationData.dateBD = dateBD
            self?.showUserDataInput()
        }
        presenter?.setViewController(vc)
    }
    
    func showUserDataInput() {
        let vc = UserDataViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .experience)
        vc.configureEnadle(false)
        vc.hideBackButton(false)
        vc.onNext = { [weak self] postion, experience in
            self?.registrationData.position = postion
            self?.registrationData.experience = experience
            self?.createAvatar()
        }

        presenter?.pushViewController(vc)
    }
    
    func createAvatar() {
        let vc = CreateAvatarViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .avatar)
        vc.changeNextButtonView(title: "Пропустить", titleColor: Constants.Colors.textColor)
        vc.onNext = { [weak self] avatar in
            if let imageData = avatar?.pngData() {
                self?.registrationData.image = imageData
            }
            self?.chooseCity()
        }
        if let registPresenter = presenter as? RegistPresenter {
            registPresenter.view = vc
        }
        presenter?.pushViewController(vc)
    }
    
    func chooseCity() {
        let vc = CityViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .geo)
        vc.configureEnadle(false)
        vc.onNext = { [weak self] city in
            self?.registrationData.city = city
            self?.acceptNotification()
        }
        presenter?.pushViewController(vc)
    }
    
    func acceptNotification() {
        let vc = NotificationViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .pushNotif)
        vc.changeNextButtonView(title: "Пропустить", titleColor: Constants.Colors.textColor, backColor: Constants.Colors.buttonInActiveColor)
        vc.onNext = { [weak self] in
            self?.showSuccess()
        }
        if let registPresenter = presenter as? RegistPresenter {
            registPresenter.view = vc
        }
        presenter?.pushViewController(vc)
    }
    
    func showSuccess() {
        let vc = RegistrationViewController(presenter: presenter)
        vc.hideBackButton(true)
        presenter?.pushViewController(vc)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.presenter?.completeRegistration(model: registrationData)
            self.onRegistrationComplete?()
        }
    }

    // MARK: - Deinit
    deinit {
        print("RegistrationCoordinator deallocated")
    }
}

// MARK: - Data Model
struct RegistrationData: Codable {
    var id: String = ""
    var email: String = ""
    var name: String = "Name"
    var surname: String = "Surname"
    var dateBD: Date?
    var position: String = "Вратарь"
    var experience: String = "1 год"
    var image: Data?
    var city: String = "Санкт-Петербург"
}
