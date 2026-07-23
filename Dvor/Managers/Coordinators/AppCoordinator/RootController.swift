
import UIKit

final class RootController {

    private weak var window: UIWindow?

    init(window: UIWindow) {
        self.window = window
    }

    func setRoot(_ vc: UIViewController) {

        guard let window else { return }
        
        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve, animations: {
                window.rootViewController = vc
            }
        )
    }
}
