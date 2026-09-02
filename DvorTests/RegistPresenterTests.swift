//import XCTest
//import UIKit
//import Foundation
//import UserNotifications
//@testable import Dvor
//
//// MARK: - Tests
//
//final class RegistPresenterTests: XCTestCase {
//    
//    private var authManager: AuthManagerMock!
//    private var dataManager: DataManagerMock!
//    private var view: RegistViewMock!
//    private var sut: RegistPresenter!
//    
//    override func setUp() {
//        super.setUp()
//        authManager = AuthManagerMock()
//        dataManager = DataManagerMock()
//        view = RegistViewMock()
//        
//        sut = RegistPresenter(
//            router: nil,
//            firebase: authManager,
//            network: dataManager
//        )
//        sut.view = view
//    }
//    
//    override func tearDown() {
//        authManager = nil
//        dataManager = nil
//        view = nil
//        sut = nil
//        super.tearDown()
//    }
//    
//    func test_updateNickname_trimsWhitespaceBeforeSaving() {
//        // given
//        let input = "  Nik  "
//        
//        // when
//        sut.updateNickname(nickname: input)
//        
//        // then
//        XCTAssertTrue(dataManager.updateUserCalled)
//        XCTAssertEqual(dataManager.lastUserId, "test-user-id")
//        XCTAssertEqual(dataManager.lastFields?["name"] as? String, "Nik")
//    }
//    
//    func test_updateNickname_emptyAfterTrim_showsErrorAndDoesNotCallNetwork() {
//        // given
//        let input = "    "
//        
//        // when
//        sut.updateNickname(nickname: input)
//        
//        // then
//        XCTAssertTrue(view.showErrorCalled)
//        XCTAssertFalse(dataManager.updateUserCalled)
//    }
//    
//    func test_updateNickname_userNotAuthorized_doesNotCallNetwork() {
//        // given
//        authManager.currentUserId = nil
//        
//        // when
//        sut.updateNickname(nickname: "Nik")
//        
//        // then
//        XCTAssertFalse(dataManager.updateUserCalled)
//    }
//    
//    func test_updateNickname_onSuccess_hidesLoading() {
//        // given
//        dataManager.updateUserResult = .success(())
//        
//        // when
//        sut.updateNickname(nickname: "Nik")
//        
//        // then
//        XCTAssertTrue(view.hideLoadingCalled)
//    }
//    
//    func test_updateNickname_onFailure_hidesLoading() {
//        // given
//        dataManager.updateUserResult = .failure(TestError(message: "Network is down"))
//        
//        // when
//        sut.updateNickname(nickname: "Nik")
//        
//        // then
//        XCTAssertTrue(view.hideLoadingCalled)
//    }
//    // MARK: - Test helpers
//    
//    private func makeSUT(
//        router: RouterMock? = nil,
//        photoManager: PhotoManagerMock? = nil,
//        notifManager: NotificationManagerMock? = nil,
//        appCoordinator: AppCoordinatorMock? = nil
//    ) -> (sut: RegistPresenter, auth: AuthManagerMock, network: DataManagerMock, view: RegistViewMock) {
//        let auth = AuthManagerMock()
//        let network = DataManagerMock()
//        let view = RegistViewMock()
//        
//        let sut = RegistPresenter(
//            router: router,
//            firebase: auth,
//            network: network,
//            photoManager: photoManager,
//            notifManager: notifManager,
//            locationManager: nil,
//            appCoordinator: appCoordinator
//        )
//        sut.view = view
//        
//        return (sut, auth, network, view)
//    }
//    
//    private func makeTestImage(size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { context in
//            UIColor.red.setFill()
//            context.fill(CGRect(origin: .zero, size: size))
//        }
//    }
//    
//    // MARK: - completeRegistration
//    
//    func test_completeRegistration_userIdNilAfterSignUp_showsUnauthorizedAlertAndDoesNotWriteUser() {
//        // given
//        let router = RouterMock()
//        let (sut, auth, network, _) = makeSUT(router: router)
//        auth.currentUserId = nil
//        let model = RegistrationData(name: "Nik", city: "Riga")
//        
//        // when
//        sut.completeRegistration(model: model)
//        
//        // then
//        XCTAssertTrue(auth.signUpCalled)
//        XCTAssertTrue(router.showAlertWithTitleCalled)
//        XCTAssertFalse(network.writeUserCalled)
//    }
//    
//    func test_completeRegistration_success_showsHome() {
//        // given
//        let appCoordinator = AppCoordinatorMock()
//        let (sut, auth, network, _) = makeSUT(appCoordinator: appCoordinator)
//        auth.currentUserId = "user-42"
//        network.writeUserResult = .success("user-42")
//        let model = RegistrationData(name: "Nik", position: "Forward", experience: "3 years", city: "Riga")
//        
//        // when
//        sut.completeRegistration(model: model)
//        
//        // then
//        XCTAssertTrue(network.writeUserCalled)
//        XCTAssertEqual(network.lastWriteUserModel?.id, "user-42")
//        XCTAssertEqual(network.lastWriteUserModel?.name, "Nik")
//        XCTAssertEqual(network.lastWriteUserModel?.city, "Riga")
//        XCTAssertTrue(appCoordinator.showHomeCalled)
//    }
//    
//    func test_completeRegistration_writeUserFails_showsAlertWithErrorMessage() {
//        // given
//        let router = RouterMock()
//        let appCoordinator = AppCoordinatorMock()
//        let (sut, auth, network, _) = makeSUT(router: router, appCoordinator: appCoordinator)
//        auth.currentUserId = "user-42"
//        network.writeUserResult = .failure(TestError(message: "Network is down"))
//        let model = RegistrationData(name: "Nik", city: "Riga")
//        
//        // when
//        sut.completeRegistration(model: model)
//        
//        // then
//        XCTAssertTrue(router.showAlertWithTitleCalled)
//        XCTAssertEqual(router.lastAlertTitle, "Network is down")
//        XCTAssertFalse(appCoordinator.showHomeCalled)
//    }
//    
//    // MARK: - pickPhoto
//    
//    func test_pickPhoto_managerIsNil_showsError() {
//        // given
//        let (sut, _, _, view) = makeSUT(photoManager: nil)
//        
//        // when
//        sut.pickPhoto()
//        
//        // then
//        XCTAssertTrue(view.showErrorCalled)
//    }
//    
//    func test_pickPhoto_success_updatesAvatarAndShowsSuccess() {
//        // given
//        let photoManager = PhotoManagerMock()
//        let testImage = UIImage()
//        photoManager.resultToReturn = .success(testImage)
//        let (sut, _, _, view) = makeSUT(photoManager: photoManager)
//        
//        // when
//        sut.pickPhoto()
//        
//        // then
//        XCTAssertTrue(view.updateAvatarImageCalled)
//        XCTAssertTrue(view.lastAvatarImage === testImage)
//        XCTAssertTrue(view.showSuccessCalled)
//        XCTAssertTrue(view.hideLoadingCalled)
//        XCTAssertFalse(view.showErrorCalled)
//    }
//    
//    func test_pickPhoto_cancelled_doesNotShowError() {
//        // given
//        let photoManager = PhotoManagerMock()
//        photoManager.resultToReturn = .failure(.cancelled)
//        let (sut, _, _, view) = makeSUT(photoManager: photoManager)
//        
//        // when
//        sut.pickPhoto()
//        
//        // then
//        XCTAssertFalse(view.showErrorCalled)
//        XCTAssertTrue(view.hideLoadingCalled)
//    }
//    
//    func test_pickPhoto_sizeExceeded_showsError() {
//        // given
//        let router = RouterMock()
//        let photoManager = PhotoManagerMock()
//        photoManager.resultToReturn = .failure(.sizeExceeded(maxSize: SizeLimits.mb8))
//        let (sut, _, _, view) = makeSUT(router: router, photoManager: photoManager)
//
//        // when
//        sut.pickPhoto()
//
//        // then
//        XCTAssertEqual(view.showErrorCallCount, 1)
//        XCTAssertTrue(router.showAlertWithTitleCalled)
//    }
//    
//    // MARK: - appendNotification
//    
//    func test_appendNotification_managerIsNil_doesNothing() {
//        // given
//        let (sut, _, _, view) = makeSUT(notifManager: nil)
//        
//        // when
//        sut.appendNotification()
//        
//        // then
//        XCTAssertFalse(view.showLoadingCalled)
//        XCTAssertFalse(view.showSuccessCalled)
//        XCTAssertFalse(view.showErrorCalled)
//    }
//    
//    func test_appendNotification_granted_showsSuccess() {
//        // given
//        let notifManager = NotificationManagerMock()
//        notifManager.authorizationResult = (true, nil)
//        let (sut, _, _, view) = makeSUT(notifManager: notifManager)
//        
//        // when
//        sut.appendNotification()
//        
//        // then
//        XCTAssertTrue(view.showLoadingCalled)
//        XCTAssertTrue(view.showSuccessCalled)
//        XCTAssertTrue(view.hideLoadingCalled)
//        XCTAssertFalse(view.showErrorCalled)
//    }
//    
//    func test_appendNotification_notGranted_showsError() {
//        // given
//        let notifManager = NotificationManagerMock()
//        notifManager.authorizationResult = (false, nil)
//        let (sut, _, _, view) = makeSUT(notifManager: notifManager)
//        
//        // when
//        sut.appendNotification()
//        
//        // then
//        XCTAssertTrue(view.showErrorCalled)
//        XCTAssertTrue(view.hideLoadingCalled)
//    }
//    
//    func test_appendNotification_systemError_showsErrorMessage() {
//        // given
//        let notifManager = NotificationManagerMock()
//        notifManager.authorizationResult = (false, TestError(message: "Permission denied"))
//        let (sut, _, _, view) = makeSUT(notifManager: notifManager)
//        
//        // when
//        sut.appendNotification()
//        
//        // then
//        XCTAssertTrue(view.showErrorCalled)
//        XCTAssertEqual(view.lastErrorMessage, "Permission denied")
//    }
//    
//    // MARK: - updateCity
//    
//    func test_updateCity_userIdNil_showsUnauthorizedAlertAndDoesNotCallNetwork() {
//        // given
//        let router = RouterMock()
//        let (sut, auth, network, _) = makeSUT(router: router)
//        auth.currentUserId = nil
//        let city = CityModel(name: "Riga", countryCode: "LV", administrativeArea: nil, latitude: 56.9, longitude: 24.1)
//        
//        // when
//        sut.updateCity(city: city)
//        
//        // then
//        XCTAssertTrue(router.showAlertWithTitleCalled)
//        XCTAssertFalse(network.updateUserCalled)
//    }
//    
//    func test_updateCity_success_updatesFirebaseAndPopsAfterAlert() {
//        // given
//        let router = RouterMock()
//        let (sut, auth, network, _) = makeSUT(router: router)
//        auth.currentUserId = "user-42"
//        network.updateUserResult = .success(())
//        let city = CityModel(name: "Riga", countryCode: "LV", administrativeArea: nil, latitude: 56.9, longitude: 24.1)
//        
//        // when
//        sut.updateCity(city: city)
//        
//        // then
//        XCTAssertTrue(auth.updateCityCalled)
//        XCTAssertEqual(auth.lastUpdateCity?.name, "Riga")
//        XCTAssertTrue(router.showAlertWithCompletionCalled)
//        
//        // Симулируем нажатие "ОК" в алерте и проверяем, что presenter действительно
//        // просит роутер вернуться назад после этого
//        router.lastAlertCompletion?()
//        XCTAssertTrue(router.popVCCalled)
//    }
//    
//    func test_updateCity_failure_showsAlertWithErrorMessage() {
//        // given
//        let router = RouterMock()
//        let (sut, auth, network, _) = makeSUT(router: router)
//        auth.currentUserId = "user-42"
//        network.updateUserResult = .failure(TestError(message: "Network is down"))
//        let city = CityModel(name: "Riga", countryCode: "LV", administrativeArea: nil, latitude: 56.9, longitude: 24.1)
//        
//        // when
//        sut.updateCity(city: city)
//        
//        // then
//        XCTAssertTrue(router.showAlertWithTitleCalled)
//        XCTAssertEqual(router.lastAlertTitle, "Network is down")
//    }
//    
//    // MARK: - updateAvatar
//    
//    func test_updateAvatar_userIdNil_showsUnauthorizedAlertAndDoesNotCallNetwork() {
//        // given
//        let router = RouterMock()
//        let (sut, auth, network, _) = makeSUT(router: router)
//        auth.currentUserId = nil
//        
//        // when
//        sut.updateAvatar(avatar: makeTestImage())
//        
//        // then
//        XCTAssertTrue(router.showAlertWithTitleCalled)
//        XCTAssertFalse(network.updateUserCalled)
//    }
//    
//    func test_updateAvatar_emptyImage_showsPhotoError() {
//        // given
//        let (sut, auth, network, view) = makeSUT()
//        auth.currentUserId = "user-42"
//        
//        // when
//        // UIImage() без CGImage не может быть сконвертирован в JPEG — jpegData вернёт nil
//        sut.updateAvatar(avatar: UIImage())
//        
//        // then
//        XCTAssertTrue(view.showErrorCalled)
//        XCTAssertFalse(network.updateUserCalled)
//    }
//    
//    func test_updateAvatar_success_updatesViewAndCallsNetworkWithBase64() {
//        // given
//        let router = RouterMock()
//        let (sut, auth, network, view) = makeSUT(router: router)
//        auth.currentUserId = "user-42"
//        network.updateUserResult = .success(())
//        let testImage = makeTestImage()
//        
//        // when
//        sut.updateAvatar(avatar: testImage)
//        
//        // then
//        XCTAssertTrue(network.updateUserCalled)
//        XCTAssertEqual(network.lastUserId, "user-42")
//        
//        let base64String = network.lastFields?["image"] as? String
//        XCTAssertNotNil(base64String)
//        XCTAssertNotNil(Data(base64Encoded: base64String ?? ""))
//        
//        XCTAssertTrue(view.updateAvatarImageCalled)
//        XCTAssertTrue(view.showSuccessCalled)
//        XCTAssertTrue(router.showAlertWithCompletionCalled)
//    }
//    
//    func test_updateAvatar_networkFailure_showsAlertWithErrorMessage() {
//        // given
//        let router = RouterMock()
//        let (sut, auth, network, _) = makeSUT(router: router)
//        auth.currentUserId = "user-42"
//        network.updateUserResult = .failure(TestError(message: "Network is down"))
//        
//        // when
//        sut.updateAvatar(avatar: makeTestImage())
//        
//        // then
//        XCTAssertTrue(router.showAlertWithTitleCalled)
//        XCTAssertEqual(router.lastAlertTitle, "Network is down")
//    }
//}
//
//
//// MARK: - Общая тестовая ошибка
//
//struct TestError: LocalizedError {
//    let message: String
//    var errorDescription: String? { message }
//}
//
//// MARK: - FirebaseAuthManagerProtocol
//
//final class AuthManagerMock: FirebaseAuthManagerProtocol {
//    var currentUserId: String? = "test-user-id"
//    var currentCity: CityModel? = nil
//    var isAuthorized: Bool = true
//    var isVerified: Bool = true
//
//    private(set) var signUpCalled = false
//    private(set) var lastSignUpCity: CityModel?
//
//    private(set) var updateCityCalled = false
//    private(set) var lastUpdateCity: CityModel?
//
//    func signUp(city: CityModel) {
//        signUpCalled = true
//        lastSignUpCity = city
//    }
//    func signIn(completion: @escaping (String) -> Void) {}
//    func signOut(completion: @escaping () -> Void) {}
//    func updateCity(city: CityModel) {
//        updateCityCalled = true
//        lastUpdateCity = city
//    }
//}
//
//// MARK: - FirebaseDataManagerProtocol
//
//final class DataManagerMock: FirebaseDataManagerProtocol {
//
//    // updateUser
//    private(set) var updateUserCalled = false
//    private(set) var lastUserId: String?
//    private(set) var lastFields: [String: Any]?
//    var updateUserResult: Result<Void, Error> = .success(())
//
//    func updateUser(userId: String, fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
//        updateUserCalled = true
//        lastUserId = userId
//        lastFields = fields
//        completion(updateUserResult)
//    }
//
//    // writeUser
//    private(set) var writeUserCalled = false
//    private(set) var lastWriteUserModel: UserModel?
//    var writeUserResult: Result<String, Error> = .success("test-user-id")
//
//    func writeUser(model: UserModel, completion: @escaping (Result<String, Error>) -> Void) {
//        writeUserCalled = true
//        lastWriteUserModel = model
//        completion(writeUserResult)
//    }
//
//    // Остальное этим тестам не нужно
//    func fetchEvents(completion: @escaping (Result<[EventModel], Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func fetchEvent(idEvent: String, completion: @escaping (Result<EventModel, Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func fetchUser(idUser: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func fetchAllUsersFromEvent(usersID: [String], orgId: String, completion: @escaping (Result<([UserModel], OrganizatorModel?), Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func writeEvents(model: EventModel, completion: @escaping (Result<String, Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func writeUserToEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func deleteEvent(idEvent: String, completion: @escaping (Result<String, Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func removeUserFromEvent(idEvent: String, idUser: String, completion: @escaping (Result<[String], Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func removeUser(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func hasEventOnSameDay(userId: String, date: Date, excludingEventId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func countEvents(forOrganizer orgId: String, on date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
//        fatalError("Not used in this test")
//    }
//}
//
//// MARK: - RegistProtocol (view)
//
//final class RegistViewMock: RegistProtocol {
//    private(set) var showErrorCalled = false
//    private(set) var showErrorCallCount = 0
//    private(set) var lastErrorMessage: String?
//    private(set) var showSuccessCalled = false
//    private(set) var showLoadingCalled = false
//    private(set) var hideLoadingCalled = false
//    private(set) var updateAvatarImageCalled = false
//    private(set) var lastAvatarImage: UIImage?
//
//    func showError(_ message: String) {
//        showErrorCalled = true
//        showErrorCallCount += 1
//        lastErrorMessage = message
//    }
//    func showSuccess() { showSuccessCalled = true }
//    func showLoading() { showLoadingCalled = true }
//    func hideLoading() { hideLoadingCalled = true }
//    func updateAvatarImage(_ image: UIImage) {
//        updateAvatarImageCalled = true
//        lastAvatarImage = image
//    }
//    func showInfoInput() {}
//}
//
//// MARK: - AppCoordinatorProtocol
//
//final class AppCoordinatorMock: AppCoordinatorProtocol {
//    private(set) var startCalled = false
//    private(set) var showHomeCalled = false
//    private(set) var showOnboardingCalled = false
//
//    func start() { startCalled = true }
//    func showHome() { showHomeCalled = true }
//    func showOnboarding() { showOnboardingCalled = true }
//}
//
//// MARK: - PhotoManagerProtocol
//
//final class PhotoManagerMock: PhotoManagerProtocol {
//    var resultToReturn: Result<UIImage, PhotoError> = .failure(.cancelled)
//
//    private(set) var pickPhotoCalled = false
//    private(set) var lastMaxSize: Int?
//
//    func pickPhoto(from router: RouterMainProtocol?,
//                   maxSize: Int?,
//                   completion: @escaping (Result<UIImage, PhotoError>) -> Void) {
//        pickPhotoCalled = true
//        lastMaxSize = maxSize
//        completion(resultToReturn)
//    }
//
//    func showPhotoPickerOptions(from router: RouterMainProtocol,
//                               maxSize: Int?,
//                               completion: @escaping (Result<UIImage, PhotoError>) -> Void) {
//        fatalError("Not used in this test")
//    }
//}
//
//// MARK: - NotificationManagerProtocol
//
//final class NotificationManagerMock: NotificationManagerProtocol {
//    var authorizationResult: (granted: Bool, error: Error?) = (true, nil)
//
//    private(set) var requestAuthorizationCalled = false
//    private(set) var createdIdentifiers: [String] = []
//    private(set) var cancelledIdentifiers: [String] = []
//
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        requestAuthorizationCalled = true
//        completion(authorizationResult.granted, authorizationResult.error)
//    }
//
//    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
//        fatalError("Not used in this test")
//    }
//
//    func createNotification(identifier: String, title: String, body: String, date: Date) {
//        createdIdentifiers.append(identifier)
//    }
//
//    func cancelNotification(identifier: String) {
//        cancelledIdentifiers.append(identifier)
//    }
//
//    func cancelAllNotifications() {
//        fatalError("Not used in this test")
//    }
//}
//
//// MARK: - RouterMainProtocol
//
//final class RouterMock: RouterMainProtocol {
//
//    var navigationController: UINavigationController = UINavigationController()
//    var builder: BuilderProtocol = BuilderMock()
//    var appCoordinator: AppCoordinatorProtocol?
//
//    private(set) var popVCCalled = false
//    private(set) var showAlertWithTitleCalled = false
//    private(set) var lastAlertTitle: String?
//    private(set) var showAlertWithCompletionCalled = false
//    private(set) var lastAlertWithCompletionTitle: String?
//    private(set) var lastAlertCompletion: (() -> Void)?
//
//    func pushVC(_ vc: UIViewController) {}
//    func presentVC(_ vc: UIViewController) {}
//    func popVC() {
//        popVCCalled = true
//    }
//    func dismiss() {}
//    func setVC(_ vc: UIViewController) {}
//
//    func pushProfileVC(model: UserModel?) {
//        fatalError("Not used in this test")
//    }
//    func pushDetailVC(model: DetailModel) {
//        fatalError("Not used in this test")
//    }
//    func pushDetailOrgInfo(model: OrganizatorModel) {
//        fatalError("Not used in this test")
//    }
//    func pushCreateEvent(date: Date) {
//        fatalError("Not used in this test")
//    }
//
//    func showAlertWithTitle(_ title: String) {
//        showAlertWithTitleCalled = true
//        lastAlertTitle = title
//    }
//
//    func showAlertWithCompletion(_ title: String, completion: (() -> Void)?) {
//        showAlertWithCompletionCalled = true
//        lastAlertWithCompletionTitle = title
//        lastAlertCompletion = completion
//    }
//
//    func showBottomSheetAlertForUser(model: UserModel) {
//        fatalError("Not used in this test")
//    }
//    func showAlertConfigur(title: String, message: String?, titleActionButton: String?, handelr: @escaping () -> Void) {
//        fatalError("Not used in this test")
//    }
//    func showShareSheet(items: [Any], completion: @escaping (Bool) -> Void) {
//        fatalError("Not used in this test")
//    }
//    func showEditAlert(model: UserModel) {
//        fatalError("Not used in this test")
//    }
//    func showLocationOnMap(location: String) {
//        fatalError("Not used in this test")
//    }
//}
//
//// MARK: - BuilderProtocol (нужен только как заглушка для RouterMock.builder)
//
//final class BuilderMock: BuilderProtocol {
//    func createRegistrationPresenter(router: RouterMainProtocol, coordinator: AppCoordinatorProtocol?) -> RegistPresenter {
//        fatalError("Not used in this test")
//    }
//    func createEditPresenter(router: RouterMainProtocol,
//                              photoManager: PhotoManagerProtocol?,
//                              notifManager: NotificationManagerProtocol?,
//                              locationManager: LocationManagerProtocol?) -> RegistPresenter {
//        fatalError("Not used in this test")
//    }
//    func createDetailVC(router: RouterMainProtocol, model: DetailModel) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//    func createDetailOrgInfo(router: RouterMainProtocol, model: OrganizatorModel) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//    func createCreateEventVC(router: RouterMainProtocol, date: Date) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//    func createHomeVC(router: RouterMainProtocol) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//    func createEditNickname(router: RouterMainProtocol, userModel: UserModel) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//    func createEditAvatar(router: RouterMainProtocol, userModel: UserModel) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//    func createEditGeo(router: RouterMainProtocol, userModel: UserModel) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//    func createProfileVC(router: RouterMainProtocol, model: UserModel?, appCoordinator: AppCoordinatorProtocol?) -> UIViewController {
//        fatalError("Not used in this test")
//    }
//}
