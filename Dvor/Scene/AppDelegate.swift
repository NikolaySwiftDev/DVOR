import UIKit
import FirebaseDatabaseInternal
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
//        IQKeyboardManager.shared.enableAutoToolbar = false
        
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Database.database().goOffline()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Database.database().goOnline()
    }
}
