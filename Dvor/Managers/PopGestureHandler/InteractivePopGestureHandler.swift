import UIKit
final class InteractivePopGestureHandler: NSObject {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        attach()
    }

    private func attach() {
        guard let gesture = navigationController?.interactivePopGestureRecognizer else { return }
        gesture.delegate = self
        gesture.isEnabled = true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension InteractivePopGestureHandler: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController else { return false }
        guard navigationController.viewControllers.count > 1 else { return false }

        if let top = navigationController.topViewController as? DisablesInteractivePop,
           top.isInteractivePopDisabled {
            return false
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

protocol DisablesInteractivePop: AnyObject {
    var isInteractivePopDisabled: Bool { get }
}
