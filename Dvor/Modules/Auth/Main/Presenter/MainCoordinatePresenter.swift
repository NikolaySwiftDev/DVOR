import Foundation

protocol MainCoordinatePresenterProtocol: AnyObject {
    init(router: RouterMainProtocol)
    func pushRegistVC()
    func pushMainView()
    func pushAuthVC()
    func openPrivacyPolicy()
    func openTermsOfUse()
}

final class MainCoordinatePresenter: MainCoordinatePresenterProtocol {
    let router: RouterMainProtocol

    required init(router: RouterMainProtocol) {
        self.router = router
    }
    
    func pushMainView() {
        router.pushHomeVC()
    }
    
    func pushRegistVC() {
        router.pushRegistVC(isNewAcc: true)
    }
    
    func pushAuthVC() {
        router.pushAuthVC()
    }
    
    func openPrivacyPolicy() {
        router.openLink(AppLinks.privacy)
    }

    func openTermsOfUse() {
        router.openLink(AppLinks.terms)
    }
    
    deinit {
//        print(#function, self)
    }
}

