
import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    
    var presenter: ProfilePresenter?
        
    //MARK: - Properties
    private let userCard = UserCardView()
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))

    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.getProfileInto()
        
        setupView()
        setupConstraint()
    }
    
    //MARK: -Back Button Tapped
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    //MARK: - Deinit
    deinit {
        print(#function, "ProfileViewController")
    }
}

//MARK: - Profile Protocol
extension ProfileViewController: ProfileProtocol {
    func success(model: UserModel) {
        userCard.configure(with: model)
    }
    
    func error(error: Error) {}
}

//MARK: - Setup view and constraints and config
private extension ProfileViewController {
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(userCard)
        view.addSubview(backButton) // Кнопка поверх карточки
    }
    
    private func setupConstraint() {
        userCard.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
        }
    }
}

