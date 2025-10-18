
import Foundation
import UIKit

protocol BuilderProtocol: AnyObject {
    func createTabbarVC(router: RouterMainProtocol) -> UIViewController
    func createRegistrationCoordinator(router: RouterMainProtocol)
    func createAuthVC(router: RouterMainProtocol) -> UIViewController
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController
    func createDetailOrgInfo(router: RouterMainProtocol, model: OrganizatorModel) -> UIViewController
    func createDetailUserInfo(router: RouterMainProtocol, model: UserModel) -> UIViewController
    func createRatingVC(router: RouterMainProtocol, model: UserModel) -> UIViewController
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController
    
    //Для отмены от таббара
    func createHomeVC(router: RouterMainProtocol) -> UIViewController
    func createProfileVC(router: RouterMainProtocol) -> UIViewController
}

class Builder: BuilderProtocol {

    var registrationCoordinator: RegistrationCoordinator?

    //MARK: - Tab bar Builder
    func createTabbarVC(router: RouterMainProtocol) -> UIViewController {

        let homeModel = TabBarModel(vc: createHomeVC(router: router),
                                    selectedImage: "soccerball")
        
        let marketModel = TabBarModel(vc: createEmptyVC(.systemYellow),
                                      selectedImage: "trophy")
        
        let walletModel = TabBarModel(vc: createEmptyVC(.systemBlue),
                                      selectedImage: "cart")

        let documentModel = TabBarModel(vc: createEmptyVC(.systemMint),
                                         selectedImage: "ticket")
        
        let personModel = TabBarModel(vc: createProfileVC(router: router),
                                    selectedImage: "person.circle")
                                        
        
        let tabbarControllers = TabBarModels(cells: [marketModel,
                                                     walletModel,
                                                     homeModel,
                                                     documentModel,
                                                     personModel
                                                    ])
        
        let view = TabBarViewController()
        let presenter = TabBarPresenter(view: view, model: tabbarControllers)
        view.presenter = presenter

        return view
    }
    
    func createRegistrationCoordinator(router: RouterMainProtocol) {
        let userDefaults = UserDefaultsManager()
//        let firebase = FirebaseManager()
        let network = FirebaseDataManager()
        let photoManager = PhotoManager()
        let notifManager = NotificationManager()
        
        let presenter = RegistPresenter(
            router: router,
            network: network,
//            firebase: firebase,
            userDefaults: userDefaults,
            photoManager: photoManager,
            notifManager: notifManager
        )
        
        registrationCoordinator = RegistrationCoordinator(presenter: presenter)
        registrationCoordinator?.onRegistrationComplete = { [weak self] in
            guard let self = self else { return }
            registrationCoordinator = nil
        }
        registrationCoordinator?.start()
    }

    //MARK: - Empty Builder
    func createEmptyVC(_ color: UIColor) -> UIViewController {
        let view = UIViewController()
        view.view.backgroundColor = color
        return view
    }
    
    //MARK: -  Auth Builder
    func createAuthVC(router: RouterMainProtocol) -> UIViewController {
        let view = AuthViewController()
        let userDefaults = UserDefaultsManager()
        let presenter = AuthPresenter(view: view, router: router, userDefaults: userDefaults)
        view.presenter = presenter
        return view
    }
    
    //MARK: -  Home Builder
    func createHomeVC(router: RouterMainProtocol) -> UIViewController {
        let view = EventsViewController()
        let network = FirebaseDataManager()
        let userDefaults = UserDefaultsManager()
        let presenter = EventsPresenter(view: view, router: router, network: network, userDefaults: userDefaults)
        view.presenter = presenter
        return view
    }
    
    //MARK: -  Profile Builder
    func createProfileVC(router: RouterMainProtocol) -> UIViewController {
        let view = ProfileViewController()
        let userDefaults = UserDefaultsManager()
        let network = FirebaseDataManager()
        let presenter = ProfilePresenter(view: view, router: router, network: network, userDefaults: userDefaults)
        view.presenter = presenter
        return view
    }

    //MARK: -  Detail Builder
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController {
        let view = DetailViewController(details: model)
        let network = FirebaseDataManager()
        let userDefaults = UserDefaultsManager()
        let presenter = DetailPresenter(view: view, router: router, network: network, userDefaults: userDefaults)
        view.presenter = presenter
        return view
    }
    
    //MARK: -  Detail Organiztor Builder
    func createDetailOrgInfo(router: RouterMainProtocol, model: OrganizatorModel) -> UIViewController {
        let view = DetailOrgInfoViewController(model: model)
        let presenter = DetailOrgInfoPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }
    
    //MARK: -  Detail User Builder
    func createDetailUserInfo(router: RouterMainProtocol, model: UserModel) -> UIViewController {
        let view = DetailUserInfoViewController(model: model)
        let presenter = DetailUserInfoPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }
    
    //MARK: - Rating Builder
    func createRatingVC(router: RouterMainProtocol, model: UserModel) -> UIViewController {
        let view = RatingViewController(model: model)
        let network = FirebaseDataManager()
        let presenter = RatingPresenter(view: view, router: router, network: network)
        view.presenter = presenter
        return view
    }
    
    //MARK: - Rating Builder
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController {
        let view = CreateEventViewController(date: date)
        let userDefaults = UserDefaultsManager()
        let network = FirebaseDataManager()
        let presenter = CreateEventPresenter(view: view, router: router, network: network, userDefaults: userDefaults)
        view.presenter = presenter
        return view
    }
    
    
}
