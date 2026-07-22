import Foundation
import UIKit


protocol BuilderProtocol: AnyObject {
    func createRegistrationPresenter(router: RouterMainProtocol) -> RegistPresenter
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController
    func createDetailOrgInfo(router: RouterMainProtocol, model: OrganizatorModel) -> UIViewController
    func createRatingVC(router: RouterMainProtocol, model: UserModel) -> UIViewController
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController
    func createHomeVC(router: RouterMainProtocol) -> UIViewController
    func createProfileVC(router: RouterMainProtocol, model: UserModel?) -> UIViewController
}

class Builder: BuilderProtocol {
    private let managers: AppContainerProtocol
    
    init(managers: AppContainerProtocol) {
        self.managers = managers
    }
    
    func createRegistrationPresenter(router: RouterMainProtocol) -> RegistPresenter {
        let presenter = RegistPresenter(
            router: router,
            firebase: managers.authManager,
            network: managers.dataManager,
            photoManager: managers.photoManager,
            notifManager: managers.notificationManager,
            locationManager: managers.locationManager
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
    func createProfileVC(router: RouterMainProtocol, model: UserModel?) -> UIViewController {
        let view = ProfileViewController(model: model)
        let presenter = ProfilePresenter(view: view,
                                         router: router,
                                         network: managers.dataManager,
                                         firebase: managers.authManager)
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
    
    //MARK: - Rating Builder
    func createRatingVC(router: RouterMainProtocol, model: UserModel) -> UIViewController {
        let view = RatingViewController(model: model)
        let presenter = RatingPresenter(view: view, router: router, network: managers.dataManager)
        view.presenter = presenter
        return view
    }
    
    //MARK: - Rating Builder
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController {
        let view = CreateEventViewController(date: date)
        let presenter = CreateEventPresenter(view: view,
                                             router: router,
                                             network: managers.dataManager,
                                             firebase: managers.authManager)
        view.presenter = presenter
        return view
    }
    
    
}
