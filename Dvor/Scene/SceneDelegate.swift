
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let navigationController = UINavigationController()
    private let builder = Builder()
    private lazy var router = Router(navigationController: navigationController,
                        builder: builder)
    
    private let firebaseDataManager = FirebaseDataManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

//        let router = Router(navigationController: navigationController,
//                            builder: builder)
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
            // Получаем ID события из параметров URL
            guard let eventId = queryItems.first(where: { $0.name == "eventId" })?.value else {
                print("⚠️ Event ID not found in deep link")
                return
            }
            
            // Загружаем конкретное событие по ID (более эффективно чем загрузка всех)
            firebaseDataManager.fetchEvent(idEvent: eventId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let event):
                    // Используем встроенный метод конвертации
                    let detailModel = event.toDetailModel()
                    
                    // Переходим на главный поток для навигации
                    DispatchQueue.main.async {
                        self.router.pushDetailVC(model: detailModel)
                    }
                    
                case .failure(let error):
                    print("❌ Failed to fetch event: \(error.localizedDescription)")
                }
            }
            
        default:
            break
        }
    }
}

// Пример deep link:
// dvor://openScreen?screen=detail&eventId=473DDA5A-2940-46FF-97AA-AA8CF31B624B
