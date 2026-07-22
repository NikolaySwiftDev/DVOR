import UIKit

protocol Coordinator: AnyObject {
    init(presenter: RegistPresenterProtocol?, window: UIWindow, router: RouterMainProtocol)
    func start()
}

protocol RegistrationCoordinatorProtocol: Coordinator {
    func showInfoInput()
    func showUserDataInput()
    func createAvatar()
    func showCity()
    func acceptNotification()
    func showSuccess()
}

final class RegistrationCoordinator: RegistrationCoordinatorProtocol {

    // MARK: - Properties
    var presenter: RegistPresenterProtocol?
    var onRegistrationComplete: (() -> Void)?
    
    private let window: UIWindow
    private let rootController: RootController
    private let router: RouterMainProtocol
    
    private var registrationData = RegistrationData()
    
    // MARK: - Initialization
    init(presenter: RegistPresenterProtocol?, window: UIWindow, router: RouterMainProtocol) {
        self.presenter = presenter
        self.window = window
        self.rootController = RootController(window: window)
        self.router = router
    }
    
    // MARK: - Start
    func start() {
        showWelcome()
    }
    
    func showWelcome() {
        let vc = WelcomeOnboardingViewController()
        vc.finish = { [weak self] in
            self?.showInfoInput()
        }
        setRoot(vc)
    }
    
    func showInfoInput() {
        let vc = InfoInputViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .info)
        vc.configureEnadle(false)
        vc.onNext = { [weak self] name, surname, dateBD in
            self?.registrationData.name = name
            self?.registrationData.surname = surname
            self?.registrationData.dateBD = dateBD
            self?.showUserDataInput()
        }
        router.pushVC(vc)
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

        router.pushVC(vc)
    }
    
    func createAvatar() {
        let vc = CreateAvatarViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .avatar)
        vc.changeNextButtonView(title: "Skip".loc, titleColor: Constants.Colors.textColor)
        vc.onNext = { [weak self] avatar in
            if let image = avatar {
                self?.registrationData.image = image.jpegData(compressionQuality: 0.3)
            }
            self?.showCity()
        }
        if let registPresenter = presenter as? RegistPresenter {
            registPresenter.view = vc
        }
        router.pushVC(vc)
    }
    
    func showCity() {
        let vc = CityViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .geo)
        vc.configureEnadle(false)
        vc.hideBackButton(false)
        vc.onNext = { [weak self] city in
            self?.registrationData.city = city.name
            self?.registrationData.countryCode = city.countryCode
            self?.registrationData.administrativeArea = city.administrativeArea
            self?.registrationData.latitude = city.latitude
            self?.registrationData.longitude = city.longitude
            
            self?.acceptNotification()
        }
        router.pushVC(vc)
    }
    
    func acceptNotification() {
        let vc = NotificationViewController(presenter: presenter)
        vc.setInfoForNavigationView(model: .pushNotif)
        vc.changeNextButtonView(title: "Skip".loc, titleColor: Constants.Colors.textColor, backColor: Constants.Colors.buttonInActiveColor)
        vc.onNext = { [weak self] in
            self?.showSuccess()
        }
        if let registPresenter = presenter as? RegistPresenter {
            registPresenter.view = vc
        }
        router.pushVC(vc)
    }
    
    func showSuccess() {
        let vc = RegistrationViewController(presenter: presenter)
        vc.hideBackButton(true)
        router.pushVC(vc)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.presenter?.completeRegistration(model: registrationData)
            self.onRegistrationComplete?()
        }
        
    }
    
    private func setRoot(_ root: UIViewController) {
        let navigation = UINavigationController(rootViewController: root)
        navigation.setNavigationBarHidden(true, animated: false)
        router.navigationController = navigation
        rootController.setRoot(navigation)
    }

    // MARK: - Deinit
    deinit {
//        print("RegistrationCoordinator deallocated")
    }
}

// MARK: - Data Model
struct RegistrationData: Codable {
    var id: String = ""
    var email: String = ""
    var name: String = "Name"
    var surname: String = "Surname"
    var dateBD: Date?
    var position: String = "Goalkeeper"
    var experience: String = "1 year"
    var image: Data?
    var city: String = ""
    var latitude: Double?
    var longitude: Double?
    var countryCode: String?
    var administrativeArea: String?
}
