
import Foundation
import UIKit
import MapKit

protocol RouterMain {
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
    func pushRegistVC()
    func pushTabBarVC()
    func pushDetailVC(model: EventModel)
    func pushDetailOrgInfo(model: OrganizatorModel)
    func pushDetailUserInfo(model: UserModel)
    func pushRatingVC(model: UserModel)
 
    func showErrorAlerWithTitle(_ title: String)
    func showBottomSheetAlertForUser(model: UserModel)
    func showAuthErrorAlert(handelr: @escaping()->())
    
    func showLocationOnMap(location: String)
}

class Router: RouterMainProtocol {

    var navigationController: UINavigationController
    var userDefaults: UserDefaultsProtocol
    var builder: BuilderProtocol?
    
    init(navigationController: UINavigationController,
         builder: BuilderProtocol,
         userDefaults: UserDefaultsProtocol) {
        
        self.navigationController = navigationController
        self.builder = builder
        self.userDefaults = userDefaults
 
    }
    
    //MARK: - Initial View Controller
    func initialViewController() {
        if userDefaults.getAuthorizationStatus() {
            guard let mainVC = builder?.createTabbarVC(router: self) else { return }
            navigationController.viewControllers = [mainVC]
            navigationController.setNavigationBarHidden(true, animated: true)
            
        } else {
            guard let mainVC = builder?.createAuthVC(router: self) else { return }
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationController.viewControllers = [mainVC]
        }
    }
    
    //MARK: - Push Tab Bar View Controller
    func pushTabBarVC() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let tabbarVC = builder?.createTabbarVC(router: self) else {
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

    //MARK: - Push Auth View Controller
    func pushAuthVC() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let tabbarVC = builder?.createAuthVC(router: self) else {
            return
        }
        
        navigationController = UINavigationController(rootViewController: tabbarVC)
        navigationController.setNavigationBarHidden(true, animated: true)
        sceneDelegate.window?.rootViewController = navigationController
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    //MARK: - Push to Regist VC
    func pushRegistVC() {
        builder?.createRegistrationCoordinator(router: self)
    }
    
    //MARK: - Push to Detail VC
    func pushDetailVC(model: EventModel) {
        guard let detailVC = builder?.createDetailVC(router: self, model: model) else { return }
        
        if let tabBarController = navigationController.topViewController as? UITabBarController {
            if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                selectedNavigationController.pushViewController(detailVC, animated: true)
            }
        }
    }

    //MARK: - Log Out
    func logOut() {
        userDefaults.setAuthorizationStatus(false)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let tabbarVC = builder?.createAuthVC(router: self) else {
            return
        }
        
        navigationController = UINavigationController(rootViewController: tabbarVC)
        sceneDelegate.window?.rootViewController = navigationController
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    //MARK: - Push Detail Organizator Info
    func pushDetailOrgInfo(model: OrganizatorModel) {
        guard let detailVC = builder?.createDetailOrgInfo(router: self, model: model) else { return }
        detailVC.modalPresentationStyle = .popover
        navigationController.present(detailVC, animated: true)
    }

    //MARK: - Push Detail User Info
    func pushDetailUserInfo(model: UserModel) {
        guard let detailVC = builder?.createDetailUserInfo(router: self, model: model) else { return }
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    //MARK: - Push Rating VC
    func pushRatingVC(model: UserModel) {
        guard let detailVC = builder?.createRatingVC(router: self, model: model) else { return }
        navigationController.pushViewController(detailVC, animated: true)
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

    //MARK: - Show Auth Error Alert
    func showAuthErrorAlert(handelr: @escaping()->()) {
        let alert = UIAlertController(title: "Неверное имя или почта",
                                      message: nil,
                                      preferredStyle: .alert)
        let repeatAction = UIAlertAction(title: "Очистить",
                                         style: .default) { handler in
            handelr()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .default)
        
        alert.addAction(repeatAction)
        alert.addAction(cancelAction)
        
        navigationController.present(alert, animated: true)
    }
    
    //MARK: - Show Network Data
    func showErrorAlerWithTitle(_ title: String) {
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Отмена",
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
            pushDetailUserInfo(model: model)
        }
        
        let events = UIAlertAction(title: "Оценка",
                                   style: .default) {[weak self] _ in
            guard let self = self else { return }
            pushRatingVC(model: model)
        }
        
        let cancel = UIAlertAction(title: "Отмена",
                                   style: .destructive)
        
        alert.addAction(profile)
        alert.addAction(events)
        alert.addAction(cancel)
        
        navigationController.present(alert, animated: true)
    }
    
    //MARK: - Show Bottom Sheet Alert
    private func showImagePickerAlert() {
        let alert = UIAlertController(title: "Выбрать фото", message: nil, preferredStyle: .actionSheet)
        
        // Камера
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Сделать фото", style: .default) { _ in
//                self.openCamera()
            })
        }
        
        // Галерея
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
//            self.openGallery()
        })
        
        // Удалить фото (если уже выбрано)
        alert.addAction(UIAlertAction(title: "Удалить фото", style: .destructive) { _ in
//                self.removePhoto()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        navigationController.present(alert, animated: true)
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
