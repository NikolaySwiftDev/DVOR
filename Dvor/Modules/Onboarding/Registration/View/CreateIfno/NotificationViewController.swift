import UIKit


final class NotificationViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: (() -> Void)?
    
    
    //MARK: - View Didload
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.appendNotification()
    }

    //MARK: - Next Button Action
    override func nextButtonTapped() {
        onNext?()
    }
}

//MARK: - Regist Protocol
extension NotificationViewController: RegistProtocol {
    func showInfoInput() {}
    func showError(_ message: String) {
        print("Error ---", message)
        onNext?()
    }
    
    func showSuccess() {
        onNext?()
    }
    
    func showLoading() {
        hideLoadingView(with: view, tag: 52, state: .add)
    }
    
    func hideLoading() {
        hideLoadingView(with: view, tag: 52, state: .delete)
    }
    
    func updateAvatarImage(_ image: UIImage) {}
    
}
