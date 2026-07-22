
import Foundation
import UIKit


protocol BuilderProtocol: AnyObject {
    func createRegistrationCoordinator(router: RouterMainProtocol) -> RegistPresenter
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController
    func createDetailOrgInfo(router: RouterMainProtocol, model: OrganizatorModel) -> UIViewController
    func createRatingVC(router: RouterMainProtocol, model: UserModel) -> UIViewController
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController
    func createHomeVC(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol) -> UIViewController
    func createProfileVC(router: RouterMainProtocol, model: UserModel?) -> UIViewController
}

class Builder: BuilderProtocol {

//    var registrationCoordinator: RegistrationCoordinator?

//    func createRegistrationCoordinator(router: RouterMainProtocol) {
//        let network = FirebaseDataManager()
//        let photoManager = PhotoManager()
//        let notifManager = NotificationManager()
//        let locationManager = LocationManager()
//        let firebase = MockFirebaseAuthManager()
//        
//        let presenter = RegistPresenter(
//            router: router,
//            firebase: firebase,
//            network: network,
//            photoManager: photoManager,
//            notifManager: notifManager,
//            locationManager: locationManager
//        )
//        
//        registrationCoordinator = RegistrationCoordinator(presenter: presenter)
//        registrationCoordinator?.onRegistrationComplete = { [weak self] in
//            guard let self = self else { return }
//            registrationCoordinator = nil
//        }
//        registrationCoordinator?.start()
//    }
    
    func createRegistrationCoordinator(router: RouterMainProtocol) -> RegistPresenter {
        let network = FirebaseDataManager()
        let photoManager = PhotoManager()
        let notifManager = NotificationManager()
        let locationManager = LocationManager()
        let firebase = MockFirebaseAuthManager()
        
        let presenter = RegistPresenter(
            router: router,
            firebase: firebase,
            network: network,
            photoManager: photoManager,
            notifManager: notifManager,
            locationManager: locationManager
        )
        
        return presenter
    }
        
    //MARK: -  Home Builder
    func createHomeVC(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol) -> UIViewController {
        let view = EventsViewController()
        let firebase = MockFirebaseAuthManager()
        let network = FirebaseDataManager()
        let presenter = EventsPresenter(view: view,
                                        router: router,
                                        network: network,
                                        firebase: firebase,
                                        coordinator: coordinator)
        view.presenter = presenter
        return view
    }
    
    //MARK: -  Profile Builder
    func createProfileVC(router: RouterMainProtocol, model: UserModel?) -> UIViewController {
        let view = ProfileViewController(model: model)
        let firebase = MockFirebaseAuthManager()
        let network = FirebaseDataManager()
        let presenter = ProfilePresenter(view: view,
                                         router: router,
                                         network: network,
                                         firebase: firebase)
        view.presenter = presenter
        return view
    }

    //MARK: -  Detail Builder
    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController {
        let view = DetailViewController(details: model)
        let firebase = MockFirebaseAuthManager()
        let network = FirebaseDataManager()
        let notification = NotificationManager()
        let presenter = DetailPresenter(view: view,
                                        router: router,
                                        network: network,
                                        firebase: firebase,
                                        notification: notification)
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
        let network = FirebaseDataManager()
        let presenter = RatingPresenter(view: view, router: router, network: network)
        view.presenter = presenter
        return view
    }
    
    //MARK: - Rating Builder
    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController {
        let view = CreateEventViewController(date: date)
        let network = FirebaseDataManager()
        let firebase = MockFirebaseAuthManager()
        let presenter = CreateEventPresenter(view: view,
                                             router: router,
                                             network: network,
                                             firebase: firebase)
        view.presenter = presenter
        return view
    }
    
    
}
