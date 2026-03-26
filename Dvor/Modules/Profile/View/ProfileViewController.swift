
import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    
    var presenter: ProfilePresenter?
        
    //MARK: - Properties
    private let titleLabel = UILabel.init(text: "Профиль", font: .poppins(weight: .bold, size: .big), textColor: .black, textAlignment: .center)
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
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(userCard)
        
    }
    
    private func setupConstraint() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(80)
        }
        
        userCard.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
}

