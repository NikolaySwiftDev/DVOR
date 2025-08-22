//
//  SceneDelegate.swift
//  Dvor
//
//  Created by Николай on 15.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let builder = Builder()
        let userDefaults = UserDefaultsManager()
        let photoManager = PhotoManager()
        let notifManager = NotificationManager()
        let router = Router(navigationController: navigationController,
                            builder: builder,
                            userDefaults: userDefaults,
                            photoManager: photoManager,
                            notifManager: notifManager)
        router.initialViewController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        
    }
}

