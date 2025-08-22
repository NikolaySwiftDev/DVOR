
import UIKit

final class ProfileViewController: BaseViewController {
    
    var presenter: ProfilePresenter?
        
    //MARK: - Properties
    private let userCard = UserCardView()
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.getProfileInto()
        
        setupView()
        setupConstraint()
        configure()
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
        view.addSubview(userCard)
    }
    private func setupConstraint() {
        userCard.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(ProfileVCConstants.paddingTop)
            make.centerX.equalToSuperview()
            make.height.equalTo(350)
            make.width.equalTo(300)
        }
    }
    private func configure() {
        setNavigationTitle("Профиль")
    }
}

fileprivate struct ProfileVCConstants {
    static let padding: CGFloat = 20
    static let paddingTop: CGFloat = 100
    static let widthScreen: CGFloat = UIScreen.main.bounds.width
}
