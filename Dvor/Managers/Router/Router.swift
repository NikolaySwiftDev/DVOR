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
    
    func presentVC(_ vc: UIViewController)
    func setVC(_ vc: UIViewController)
    func pushVC(_ vc: UIViewController)
    
    func showMainCoordinateFlow()
    func pushRegistVC()
    func showMainFlow()
    func pushProfileVC(model: UserModel?)
    func pushCreateEvent(date: Date)
    func pushDetailVC(model: DetailModel)
    func pushDetailOrgInfo(model: OrganizatorModel)
    func pushRatingVC(model: UserModel)
 
    func showAlertWithTitle(_ title: String)
    func showBottomSheetAlertForUser(model: UserModel)
    func showAlertConfigur(title: String, message: String?, titleActionButton: String?, handelr: @escaping()->())
    func showShareSheet(items: [Any], completion: @escaping (Bool) -> Void)
    
    func showLocationOnMap(location: String)
}

class Router: RouterMainProtocol {

    var builder: BuilderProtocol?
    var navigationController: UINavigationController
    private let firebase = MockFirebaseAuthManager()
    private var popGestureHandler: InteractivePopGestureHandler?
    private weak var rootController: RootController?

    init(navigationController: UINavigationController, builder: BuilderProtocol, rootController: RootController) {
        self.navigationController = navigationController
        self.builder = builder
        self.rootController = rootController

        attachInteractivePopGesture()
    }

    //MARK: - Interactive Pop Gesture
    private func attachInteractivePopGesture() {
        popGestureHandler = InteractivePopGestureHandler(navigationController: navigationController)
    }
    
    //MARK: - Initial View Controller
    func initialViewController() {
        let rootVC: UIViewController

        if firebase.isAuthorized {
            guard let vc = builder?.createHomeVC(router: self) else { return }
            rootVC = vc
        } else {
            guard let vc = builder?.createOnboardPageVC(router: self) else { return }
            rootVC = vc
        }

        let navigation = makeNavigationController(root: rootVC)
        navigationController = navigation
        rootController?.setRoot(navigation)
    }
    
    //MARK: - Push Tab Bar View Controller
    func showMainFlow() {
        guard let vc = builder?.createHomeVC(router: self) else { return }
        let navigation = makeNavigationController(root: vc)
        navigationController = navigation
        rootController?.setRoot(navigation)
        
    }
    
    //MARK: - Custom VC presentation
    func presentVC(_ vc: UIViewController) {
        navigationController.present(vc, animated: true)
    }
    
    func setVC(_ vc: UIViewController) {
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func pushVC(_ vc: UIViewController) {
        navigationController.pushViewController(vc, animated: true)
    }

    //MARK: - Push Main Coordinate View Controller
    func showMainCoordinateFlow() {
        guard let vc = builder?.createMainCoordinateVC(router: self) else { return }

        let navigation = makeNavigationController(root: vc)
        navigationController = navigation
        rootController?.setRoot(navigation)
    }
    
    //MARK: - Push to Regist VC
    func pushRegistVC() {
        builder?.createRegistrationCoordinator(router: self)
    }
    
    //MARK: - Push to Detail VC
    func pushDetailVC(model: DetailModel) {
        guard let detailVC = builder?.createDetailVC(router: self, model: model) else { return }
        pushVC(detailVC)
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
        navigationController.popViewController(animated: true)
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
        
        let cancelAction = UIAlertAction(title: "Cancel".loc, style: .cancel)
        
        alert.addAction(repeatAction)
        alert.addAction(cancelAction)
        
        navigationController.present(alert, animated: true)
    }
    
    //MARK: - Show Network Data
    func showAlertWithTitle(_ title: String) {
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Ok".loc,
                                         style: .default)
        
        alert.addAction(cancelAction)
        
        navigationController.present(alert, animated: true)
    }
    
    //MARK: - Show Bottom Sheet Alert
    func showBottomSheetAlertForUser(model: UserModel) {
        let alert = UIAlertController(title: "Info user".loc,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let profile = UIAlertAction(title: "Profile".loc,
                                    style: .default) { [weak self] _ in
            guard let self = self else { return }
            pushProfileVC(model: model)

        }
        
        let cancel = UIAlertAction(title: "Cancel".loc,
                                   style: .destructive)
        
        alert.addAction(profile)
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
        
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
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
                print("Location not found")
                return
            }
            mapItem.name = location
            mapItem.openInMaps(launchOptions: nil)
        }
    }
    
    //MARK: - Make Navigation Controller
    private func makeNavigationController(root: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.setNavigationBarHidden(true, animated: false)

        popGestureHandler = InteractivePopGestureHandler(
            navigationController: navigationController
        )
        
        return navigationController
    }
}
