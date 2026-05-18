
import Foundation
import UIKit
import MapKit

protocol RouterMain: AnyObject {
    var navigationController: UINavigationController { get set }
    var builder: BuilderProtocol? { get set }
}

protocol RouterMainProtocol: RouterMain {
    func initialViewController()
    func popVC()
    func dismiss()
    func logOut()
    
    func present(_ vc: UIViewController)
    func setVC(_ vc: UIViewController)
    func pushVC(_ vc: UIViewController)
    
    func pushAuthVC()
    func pushMainCoordinateVC()
    func pushRegistVC()
    func pushTabBarVC()
    func pushProfileVC(model: UserModel?)
    func pushCreateEvent(date: Date)
    func pushDetailVC(model: DetailModel)
    func pushDetailOrgInfo(model: OrganizatorModel)
//    func pushDetailUserInfo(model: UserModel)
    func pushRatingVC(model: UserModel)
 
    func showAlertWithTitle(_ title: String)
    func showBottomSheetAlertForUser(model: UserModel)
    func showAlertConfigur(title: String, message: String?, titleActionButton: String?, handelr: @escaping()->())
    func showShareSheet(items: [Any], completion: @escaping (Bool) -> Void)
    
    func showLocationOnMap(location: String)
}

class Router: RouterMainProtocol {

    var navigationController: UINavigationController
    var builder: BuilderProtocol?
//    private let firebase = FirebaseAuthManager()
    private let firebase = MockFirebaseAuthManager()
    
    init(navigationController: UINavigationController,
         builder: BuilderProtocol) {
        
        self.navigationController = navigationController
        self.builder = builder
 
    }
    
    //MARK: - Initial View Controller
    func initialViewController() {
        if firebase.isAuthorized {
            guard let mainVC = builder?.createHomeVC(router: self) else { return }
            navigationController.viewControllers = [mainVC]
            navigationController.setNavigationBarHidden(true, animated: true)
            
        } else {
            guard let mainVC = builder?.createMainCoordinateVC(router: self) else { return }
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationController.viewControllers = [mainVC]
        }
    }
    
    //MARK: - Push Tab Bar View Controller
    func pushTabBarVC() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
//              let tabbarVC = builder?.createTabbarVC(router: self) else {
              let tabbarVC = builder?.createHomeVC(router: self) else {
            return
        }

        navigationController = UINavigationController(rootViewController: tabbarVC)
        navigationController.setNavigationBarHidden(true, animated: true)
        sceneDelegate.window?.rootViewController = navigationController
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    //MARK: - Custom VC presentation
    func present(_ vc: UIViewController) {
        navigationController.present(vc, animated: true)
    }
    
    func setVC(_ vc: UIViewController) {
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func pushVC(_ vc: UIViewController) {
        navigationController.pushViewController(vc, animated: true)
    }

    //MARK: - Push Main Coordinate View Controller
    func pushMainCoordinateVC() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let tabbarVC = builder?.createMainCoordinateVC(router: self) else {
            return
        }
        
        navigationController = UINavigationController(rootViewController: tabbarVC)
        navigationController.setNavigationBarHidden(true, animated: true)
        sceneDelegate.window?.rootViewController = navigationController
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    //MARK: - Push Auth View Controller

    func pushAuthVC() {
        guard let authVC = builder?.createAuthVC(router: self) else { return }
        pushVC(authVC)
    }
    
    //MARK: - Push to Regist VC
    func pushRegistVC() {
        builder?.createRegistrationCoordinator(router: self)
    }
    
    //MARK: - Push to Detail VC
    func pushDetailVC(model: DetailModel) {
        guard let detailVC = builder?.createDetailVC(router: self, model: model) else { return }
        pushVC(detailVC)
//        if let tabBarController = navigationController.topViewController as? UITabBarController {
//            if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
//                selectedNavigationController.pushViewController(detailVC, animated: true)
//            }
//        }
    }

    //MARK: - Log Out
    func logOut() {
        firebase.signOut { [weak self] _ in
            guard let self = self else { return }
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate,
                  let tabbarVC = builder?.createMainCoordinateVC(router: self) else {
                return
            }
            
            self.navigationController = UINavigationController(rootViewController: tabbarVC)
            sceneDelegate.window?.rootViewController = self.navigationController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    //MARK: - Push Profile User Info
    func pushProfileVC(model: UserModel?) {
        guard let detailVC = builder?.createProfileVC(router: self, model: model) else { return }
        pushVC(detailVC)
    }
    
    //MARK: - Push Detail Organizator Info
    func pushDetailOrgInfo(model: OrganizatorModel) {
        guard let detailVC = builder?.createDetailOrgInfo(router: self, model: model) else { return }
        detailVC.modalPresentationStyle = .popover
        navigationController.present(detailVC, animated: true)
    }

//    //MARK: - Push Detail User Info
//    func pushDetailUserInfo(model: UserModel) {
//        guard let detailVC = builder?.createDetailUserInfo(router: self, model: model) else { return }
//        pushVC(detailVC)
//    }
    
    //MARK: - Push Rating VC
    func pushRatingVC(model: UserModel) {
        guard let detailVC = builder?.createRatingVC(router: self, model: model) else { return }
        pushVC(detailVC)
    }
    
    //MARK: - Push Create Event VC
    func pushCreateEvent(date: Date) {
        guard let detailVC = builder?.createCreateEventVC(router: self, date: date) else { return }
        pushVC(detailVC)
    }

    //MARK: - Pop VC
    func popVC() {
        if let tabBarController = navigationController.topViewController as? UITabBarController {
            if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                selectedNavigationController.popViewController(animated: true)
            }
        } else {
            navigationController.popViewController(animated: true)
        }
    }
    
    //MARK: - Dismiss
    func dismiss() {
        navigationController.dismiss(animated: true)
    }

    //MARK: - Show Alert with Config
    func showAlertConfigur(title: String, message: String?, titleActionButton: String?, handelr: @escaping()->()) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let repeatAction = UIAlertAction(title: titleActionButton,
                                         style: .default) { handler in
            handelr()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(repeatAction)
        alert.addAction(cancelAction)
        
        navigationController.present(alert, animated: true)
    }
    
    //MARK: - Show Network Data
    func showAlertWithTitle(_ title: String) {
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Ок",
                                         style: .default)
        
        alert.addAction(cancelAction)
        
        navigationController.present(alert, animated: true)
    }
    
    //MARK: - Show Bottom Sheet Alert
    func showBottomSheetAlertForUser(model: UserModel) {
        let alert = UIAlertController(title: "Пользователь инфо",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let profile = UIAlertAction(title: "Профиль",
                                    style: .default) { [weak self] _ in
            guard let self = self else { return }
//            pushDetailUserInfo(model: model)
            pushProfileVC(model: model)

        }
        
//        let events = UIAlertAction(title: "Оценка",
//                                   style: .default) {[weak self] _ in
//            guard let self = self else { return }
//            pushRatingVC(model: model)
//        }
        
        let cancel = UIAlertAction(title: "Отмена",
                                   style: .destructive)
        
        alert.addAction(profile)
//        alert.addAction(events)
        alert.addAction(cancel)
        
        navigationController.present(alert, animated: true)
    }
    
    //MARK: - Show Share Sheet
    func showShareSheet(items: [Any], completion: @escaping (Bool) -> Void) {
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // For iPad support
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = navigationController.view
            popoverController.sourceRect = CGRect(
                x: navigationController.view.bounds.midX,
                y: navigationController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        
        // Handle completion when share sheet is dismissed
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            // Call completion handler with whether sharing was successful or cancelled
            completion(completed)
        }
        
        navigationController.present(activityViewController, animated: true)
    }
    
    //MARK: - Show Location On Map
    func showLocationOnMap(location: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let mapItem = response?.mapItems.first else {
                print("Не удалось найти локацию")
                return
            }
            mapItem.name = location
            mapItem.openInMaps(launchOptions: nil)
        }
    }
}
