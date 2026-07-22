import Foundation

protocol AppContainerProtocol: AnyObject {
    var authManager: FirebaseAuthManagerProtocol { get }
    var dataManager: FirebaseDataManagerProtocol { get }
    var notificationManager: NotificationManagerProtocol { get }
    var locationManager: LocationManagerProtocol { get }
    var photoManager: PhotoManagerProtocol { get }
}

final class AppContainer: AppContainerProtocol {
    lazy var authManager: FirebaseAuthManagerProtocol = MockFirebaseAuthManager()
    lazy var dataManager: FirebaseDataManagerProtocol = FirebaseDataManager()
    lazy var notificationManager: NotificationManagerProtocol = NotificationManager()
    lazy var locationManager: LocationManagerProtocol = LocationManager()
    lazy var photoManager: PhotoManagerProtocol = PhotoManager()
}
