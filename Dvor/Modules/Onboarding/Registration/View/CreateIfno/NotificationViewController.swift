import UIKit


final class NotificationViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: (() -> Void)?
    
    //MARK: - UI
    private let notifButton = UIButton.createStandartButton(
        title: "Включить уведомления",
        backgroundColor: Constants.Colors.buttonActiveColor,
        target: self,
        action: #selector(notifButtonTapped)
    )
    
    //MARK: - View Didload
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    //MARK: - Next Button Action
    override func nextButtonTapped() {
        onNext?()
    }
    
    //MARK: - Notify Button Action
    @objc private func notifButtonTapped() {
        presenter?.appendNotification()
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

//MARK: - setupLayout + config
private extension NotificationViewController {
    private func setupLayout() {
        view.addSubview(notifButton)
        
        notifButton.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
}
