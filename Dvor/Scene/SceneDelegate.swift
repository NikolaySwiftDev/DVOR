
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let navigationController = UINavigationController()
    let builder = Builder()



    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let router = Router(navigationController: navigationController,
                            builder: builder)
        router.initialViewController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first,
              let components = URLComponents(url: firstUrl.url, resolvingAgainstBaseURL: true) else { return }
        switch components.host {
        case "openScreen":
            openDetailScreen(with: components.queryItems ?? [])
        default:
            break
        }
    }
    
    func openDetailScreen(with queryItems: [URLQueryItem]) {
        let screenQuery = queryItems.first(where: {$0.name == "screen"})
        
        switch screenQuery?.value {
        case "detail":
            let router = Router(navigationController: navigationController,
                                builder: builder)
            router.pushProfileVC()
            print("detail")
        default:
            break
        }
    }
}

//dvor://openScreen?screen=detail&text=HelloWorld
