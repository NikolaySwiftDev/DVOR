import Foundation

protocol AppContainerProtocol {

    var authManager: FirebaseAuthManagerProtocol { get }
    var dataManager: FirebaseDataManagerProtocol { get }

    func makeCommentsManager() -> FirebaseCommentsManagerProtocol
    func makePhotoManager() -> PhotoManagerProtocol
    func makeNotificationManager() -> NotificationManagerProtocol
    func makeLocationManager() -> LocationManagerProtocol
}

final class AppContainer: AppContainerProtocol {

    let authManager: FirebaseAuthManagerProtocol
    let dataManager: FirebaseDataManagerProtocol

    init() {
        self.authManager = FirebaseAuthManager()
        self.dataManager = FirebaseDataManager()
    }


    func makeCommentsManager() -> FirebaseCommentsManagerProtocol {
        FirebaseCommentsManager()
    }

    func makePhotoManager() -> PhotoManagerProtocol {
        PhotoManager()
    }

    func makeNotificationManager() -> NotificationManagerProtocol {
        NotificationManager()
    }

    func makeLocationManager() -> LocationManagerProtocol {
        LocationManager()
    }
}
