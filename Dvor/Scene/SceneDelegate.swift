
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let builder = Builder()

        let router = Router(navigationController: navigationController,
                            builder: builder)
        router.initialViewController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        
    }
}

