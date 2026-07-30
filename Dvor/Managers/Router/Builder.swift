import Foundation
import UIKit


protocol BuilderProtocol: AnyObject {
    func createRegistrationPresenter(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol?) -> RegistPresenter
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController
    func createDetailOrgInfo(router: RouterMainProtocol, model: OrganizatorModel) -> UIViewController
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController
    func createHomeVC(router: RouterMainProtocol) -> UIViewController
    func createEditNickname(router: RouterMainProtocol, userModel: UserModel) -> UIViewController
    func createEditAvatar(router: RouterMainProtocol, userModel: UserModel) -> UIViewController
    func createEditGeo(router: RouterMainProtocol, userModel: UserModel) -> UIViewController
    func createProfileVC(router: RouterMainProtocol, model: UserModel?, appCoordinator: AppCoordinatorProtocol?) -> UIViewController
}

class Builder: BuilderProtocol {

    private let managers: AppContainerProtocol
    
    init(managers: AppContainerProtocol) {
        self.managers = managers
    }
    
    func createRegistrationPresenter(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol?) -> RegistPresenter {
        let presenter = RegistPresenter(
            router: router,
            firebase: managers.authManager,
            network: managers.dataManager,
            photoManager: managers.photoManager,
            notifManager: managers.notificationManager,
            locationManager: managers.locationManager,
            appCoordinator: coordinator
        )
        
        return presenter
    }
        
    //MARK: -  Home Builder
    func createHomeVC(router: RouterMainProtocol) -> UIViewController {
        let view = EventsViewController()
        let presenter = EventsPresenter(view: view,
                                        router: router,
                                        network: managers.dataManager,
                                        firebase: managers.authManager)
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
                                         notification: managers.notificationManager,
                                         appCoordinator: appCoordinator)
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
                                        notification: managers.notificationManager)
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
                                             firebase: managers.authManager)
        view.presenter = presenter
        return view
    }
    
    //MARK: - Edit Profile
    func createEditNickname(router: RouterMainProtocol, userModel: UserModel) -> UIViewController {
        let view = InfoInputViewController(presenter: createRegistrationPresenter(router: router, coordinator: nil))
        view.isEdit = true
        view.setInfoForNavigationView(model: .info)
        view.configureEnadle(false)
        view.hideBackButton(false)
        view.hidePageControllView()
        view.updateButtonTitle("Update".loc)
        
        return view
    }
    
    func createEditAvatar(router: any RouterMainProtocol, userModel: UserModel) -> UIViewController {
        let presenter = createRegistrationPresenter(router: router, coordinator: nil)
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
        let view = CityViewController(presenter: createRegistrationPresenter(router: router, coordinator: nil))
        view.isEdit = true
        view.setInfoForNavigationView(model: .geo)
        view.configureEnadle(false)
        view.hideBackButton(false)
        view.hidePageControllView()
        view.updateButtonTitle("Update".loc)

        return view
    }
    

}
