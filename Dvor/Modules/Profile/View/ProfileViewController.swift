
import UIKit

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
    
    func error(error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: - Setup view and constraints and config
private extension ProfileViewController {
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(backButton)
        view.addSubview(userCard)
    }
    private func setupConstraint() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
//            make.size.equalTo(Constants.Constraint.backButtonSize)
        }
        
        userCard.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(ProfileVCConstants.paddingTop)
            make.centerX.equalToSuperview()
            make.height.equalTo(350)
            make.width.equalTo(300)
        }
    }
}

fileprivate struct ProfileVCConstants {
    static let padding: CGFloat = 20
    static let paddingTop: CGFloat = 100
    static let widthScreen: CGFloat = UIScreen.main.bounds.width
}
