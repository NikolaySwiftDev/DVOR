import Foundation
import UIKit


protocol BuilderProtocol: AnyObject {
    func createRegistrationPresenter(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol?) -> RegistPresenter
    func createAuthVC(router: RouterMainProtocol) -> UIViewController
    func createRegistration(router: RouterMainProtocol) -> UIViewController
    func createEditPresenter(router: RouterMainProtocol, photoManager: PhotoManagerProtocol?, notifManager: NotificationManagerProtocol?, locationManager: LocationManagerProtocol?) -> RegistPresenter
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController
    func createDetailOrgInfo(router: RouterMainProtocol, model: OrganizatorModel) -> UIViewController
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController
    func createHomeVC(router: RouterMainProtocol) -> UIViewController
    func createEditNickname(router: RouterMainProtocol, userModel: UserModel) -> UIViewController
    func createEditAvatar(router: RouterMainProtocol, userModel: UserModel) -> UIViewController
    func createEditGeo(router: RouterMainProtocol, userModel: UserModel) -> UIViewController
    func createProfileVC(router: RouterMainProtocol, model: UserModel?, appCoordinator: AppCoordinatorProtocol?) -> UIViewController
    func createEventsMapVC(router: RouterMainProtocol, events: [EventModel]) -> UIViewController
}

class Builder: BuilderProtocol {


    private let managers: AppContainerProtocol
    
    init(managers: AppContainerProtocol) {
        self.managers = managers
    }
    
    // MARK: - Full registration flow (onboarding) — needs every manager at once
    func createRegistrationPresenter(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol?) -> RegistPresenter {
        RegistPresenter(
            router: router,
            firebase: managers.authManager,
            network: managers.dataManager,
            photoManager: managers.makePhotoManager(),
            notifManager: managers.makeNotificationManager(),
            locationManager: managers.makeLocationManager(),
            appCoordinator: coordinator,
            storage: managers.makeCityStorageManager()
        )
    }
    
    // MARK: - Single-field profile edits — only the manager the screen actually needs
    func createEditPresenter(router: RouterMainProtocol,
                              photoManager: PhotoManagerProtocol? = nil,
                              notifManager: NotificationManagerProtocol? = nil,
                              locationManager: LocationManagerProtocol? = nil) -> RegistPresenter {
        RegistPresenter(
            router: router,
            firebase: managers.authManager,
            network: managers.dataManager,
            photoManager: photoManager,
            notifManager: notifManager,
            locationManager: locationManager,
            appCoordinator: nil,
            storage: managers.makeCityStorageManager()
        )
    }
    
    func createAuthVC(router: any RouterMainProtocol) -> UIViewController {
        let view = AuthViewController()
        let presenter = AuthPresenter(router: router,
                                      firebase: managers.authManager,
                                      network: managers.dataManager,
                                      storage: managers.makeCityStorageManager())
        view.presenter = presenter
        return view
    }
    
    
    //MARK: -  Auth Builder
    func createRegistration(router: RouterMainProtocol) -> UIViewController {
        let view = MainCoordinateViewController()
        let presenter = MainCoordinatePresenter(router: router)
        view.presenter = presenter
        return view
        
    }
        
    //MARK: -  Home Builder
    func createHomeVC(router: RouterMainProtocol) -> UIViewController {
        let view = EventsViewController()
        let presenter = EventsPresenter(view: view,
                                        router: router,
                                        network: managers.dataManager,
                                        firebase: managers.authManager,
                                        storage: managers.makeCityStorageManager())
        view.presenter = presenter
        return view
    }
    
    //MARK: -  Profile Builder
    func createProfileVC(router: RouterMainProtocol, model: UserModel?, appCoordinator: AppCoordinatorProtocol?) -> UIViewController {
        let view = ProfileViewController(model: model)
        let presenter = ProfilePresenter(view: view,
                                         router: router,
                                         network: managers.dataManager,
                                         firebase: managers.authManager,
                                         notification: managers.makeNotificationManager(),
                                         appCoordinator: appCoordinator,
                                         storage: managers.makeCityStorageManager())
        view.presenter = presenter
        return view
    }

    //MARK: -  Detail Builder
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController {
        let view = DetailViewController(details: model)
        let presenter = DetailPresenter(view: view,
                                        router: router,
                                        network: managers.dataManager,
                                        firebase: managers.authManager,
                                        notification: managers.makeNotificationManager(),
                                        comments: managers.makeCommentsManager(),
                                        storage: managers.makeCityStorageManager())
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
    
    //MARK: - Create Event
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController {
        let view = CreateEventViewController(date: date)
        let presenter = CreateEventPresenter(view: view,
                                             router: router,
                                             network: managers.dataManager,
                                             firebase: managers.authManager,
                                             storage: managers.makeCityStorageManager())
        view.presenter = presenter
        return view
    }
    
    //MARK: - Edit Profile
    func createEditNickname(router: RouterMainProtocol, userModel: UserModel) -> UIViewController {
        let presenter = createEditPresenter(router: router)
        let view = InfoInputViewController(presenter: presenter)
        view.isEdit = true
        view.setInfoForNavigationView(model: .info)
        view.configureEnadle(false)
        view.hideBackButton(false)
        view.hidePageControllView()
        view.updateButtonTitle("Update".loc)
        
        return view
    }
    
    func createEditAvatar(router: any RouterMainProtocol, userModel: UserModel) -> UIViewController {
        let presenter = createEditPresenter(router: router,
                                            photoManager: managers.makePhotoManager())
        let view = CreateAvatarViewController(presenter: presenter)
        view.isEdit = true
        view.setInfoForNavigationView(model: .avatar)
        view.configureEnadle(false)
        view.hideBackButton(false)
        view.hidePageControllView()
        view.updateButtonTitle("Update".loc)
        presenter.view = view
        
        return view
    }
    
    func createEditGeo(router: any RouterMainProtocol, userModel: UserModel) -> UIViewController {
        let presenter = createEditPresenter(router: router, locationManager: managers.makeLocationManager())
        let view = CityViewController(presenter: presenter)
        view.isEdit = true
        view.setInfoForNavigationView(model: .geo)
        view.configureEnadle(false)
        view.hideBackButton(false)
        view.hidePageControllView()
        view.updateButtonTitle("Update".loc)

        return view
    }
    
    func createEventsMapVC(router: RouterMainProtocol, events: [EventModel]) -> UIViewController {
        let view = EventsMapViewController()
        let presenter = EventsMapPresenter(view: view, router: router, events: events)
        view.presenter = presenter
        return view
    }
    

}
