
import UIKit
import MapKit

protocol RouterMain: AnyObject {
    var navigationController: UINavigationController { get set }
    var builder: BuilderProtocol { get set }
}

protocol RouterMainProtocol: RouterMain {

    // Navigation
    func pushVC(_ vc: UIViewController)
    func presentVC(_ vc: UIViewController)
    func popVC()
    func dismiss()
    func setVC(_ vc: UIViewController)

    // Screens
    func pushProfileVC(model: UserModel?)
    func pushDetailVC(model: DetailModel)
    func pushDetailOrgInfo(model: OrganizatorModel)
    func pushRatingVC(model: UserModel)
    func pushCreateEvent(date: Date)

    // Alerts
    func showAlertWithTitle(_ title: String)
    func showBottomSheetAlertForUser(model: UserModel)
    func showAlertConfigur(
        title: String,
        message: String?,
        titleActionButton: String?,
        handelr: @escaping () -> Void
    )
    func showShareSheet(
        items: [Any],
        completion: @escaping (Bool) -> Void
    )

    // Map
    func showLocationOnMap(location: String)
}

final class Router: RouterMainProtocol {
    
    // MARK: - Properties
    var navigationController: UINavigationController
    var builder: BuilderProtocol

    // MARK: - Init

    init(
        navigationController: UINavigationController,
        builder: BuilderProtocol
    ) {
        self.navigationController = navigationController
        self.builder = builder
    }

    // MARK: - Navigation

    func pushVC(_ vc: UIViewController) {
        navigationController.pushViewController(vc, animated: true)
    }

    func presentVC(_ vc: UIViewController) {
        navigationController.present(vc, animated: true)
    }

    func popVC() {
        navigationController.popViewController(animated: true)
    }

    func dismiss() {
        navigationController.dismiss(animated: true)
    }

    func setVC(_ vc: UIViewController) {
        navigationController.setViewControllers([vc], animated: true)
    }

    // MARK: - Detail

    func pushDetailVC(model: DetailModel) {
        let vc = builder.createDetailVC(router: self, model: model)
        pushVC(vc)
    }

    func pushProfileVC(model: UserModel?) {
        let vc = builder.createProfileVC(router: self, model: model)
        pushVC(vc)
    }

    func pushRatingVC(model: UserModel) {
        let vc = builder.createRatingVC(router: self, model: model)
        pushVC(vc)
    }

    func pushCreateEvent(date: Date) {
        let vc = builder.createCreateEventVC(router: self, date: date)
        pushVC(vc)
    }

    func pushDetailOrgInfo(model: OrganizatorModel) {
        let vc = builder.createDetailOrgInfo(router: self, model: model)
        vc.modalPresentationStyle = .popover
        presentVC(vc)
    }

    // MARK: - Alerts

    func showAlertWithTitle(_ title: String) {

        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Ok".loc,
                style: .default
            )
        )

        presentVC(alert)
    }

    func showAlertConfigur(
        title: String,
        message: String?,
        titleActionButton: String?,
        handelr: @escaping () -> Void
    ) {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: titleActionButton,
                style: .default
            ) { _ in
                handelr()
            }
        )

        alert.addAction(
            UIAlertAction(
                title: "Cancel".loc,
                style: .cancel
            )
        )

        presentVC(alert)
    }

    func showBottomSheetAlertForUser(model: UserModel) {

        let alert = UIAlertController(
            title: "Info user".loc,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(
                title: "Profile".loc,
                style: .default
            ) { [weak self] _ in
                self?.pushProfileVC(model: model)
            }
        )

        alert.addAction(
            UIAlertAction(
                title: "Cancel".loc,
                style: .destructive
            )
        )

        presentVC(alert)
    }

    func showShareSheet(
        items: [Any],
        completion: @escaping (Bool) -> Void
    ) {

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = navigationController.view
            popover.sourceRect = CGRect(
                x: navigationController.view.bounds.midX,
                y: navigationController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        activityVC.completionWithItemsHandler = { _, completed, _, _ in
            completion(completed)
        }

        presentVC(activityVC)
    }

    // MARK: - Map

    func showLocationOnMap(location: String) {

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location

        MKLocalSearch(request: request).start { response, _ in
            guard let item = response?.mapItems.first else {
                print("Location not found")
                return
            }

            item.name = location
            item.openInMaps()
        }
    }
}
