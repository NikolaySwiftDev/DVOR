
import UIKit

final class CreateAvatarViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
//    private lazy var avatar = UIImage(systemName: "person.and.background.dotted")
    private var avatar: UIImage?
    var onNext: ((UIImage?) -> Void)?
    
    //MARK: - UI
    private lazy var avatarImageView = UIImageView(systemImage: "person.and.background.dotted", cornerRadius: 125)
    
    private let chooseFoto = UIButton.createStandartButton(
        title: "Выбрать фото",
        backgroundColor: Constants.Colors.buttonActiveColor,
        target: self,
        action: #selector(chooseFotoButtonTapped)
    )
    
    //MARK: - View Didload
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        updateNextButtonState()
    }
    
    //MARK: - ChooseFoto Button Action
    @objc private func chooseFotoButtonTapped() {
        presenter?.pickPhoto()
    }
    
    //MARK: - Next Button Action
    override func nextButtonTapped() {
        onNext?(avatar)
    }
}

extension CreateAvatarViewController: RegistProtocol {
    func showError(_ message: String) {}
    func showInfoInput() {}

    func showSuccess() {
        updateNextButtonState()
    }

    func updateAvatarImage(_ image: UIImage) {
        avatar = image
        avatarImageView.image = avatar
    }
    
    func showLoading() {
        hideLoadingView(with: view, tag: 100, state: .add)
    }

    func hideLoading() {
        hideLoadingView(with: view, tag: 100, state: .delete)
    }
}


//MARK: - setupLayout + config
extension CreateAvatarViewController {
    private func setupLayout() {
        view.addSubview(avatarImageView)
        view.addSubview(chooseFoto)
        
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(250)
        }
        
        chooseFoto.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
    
    private func updateNextButtonState() {
        let isValid = checkValidButton()
        chooseFoto.setTitle(isValid ? "Изменить фото" : "Выбрать фото", for: .normal)
        
        changeNextButtonView(title: isValid ? "Продолжить" : "Пропустить",
                             titleColor: isValid ? Constants.Colors.titleColor : Constants.Colors.textColor,
                             backColor: isValid ? Constants.Colors.buttonActiveColor : Constants.Colors.buttonInActiveColor)
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard let avatar = avatar else { return false }
        return avatar != UIImage(systemName: "person.and.background.dotted")
    }
}

