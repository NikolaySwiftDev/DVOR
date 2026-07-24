
import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    
    var presenter: ProfilePresenterProtocol?
    var model: UserModel?
        
    //MARK: - Properties
    private let titleLabel = UILabel.init(text: "common.profile".loc, font: .poppins(weight: .bold, size: .big), textColor: .black, textAlignment: .center)
    private let userCard = UserCardView()
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    private let editButton = UIButton.createStandartButton(title: "Edit profile", backgroundColor: .black, target: self, action: #selector(editButtonTapped))

    init(model: UserModel? = nil) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraint()
        
        if let model = model {
            configureUserCard(with: model)
        } else {
            presenter?.getProfileInto()
        }
    }
    
    //MARK: - Back Button Tapped
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    //MARK: - Back Button Tapped
    @objc private func editButtonTapped() {
        presenter?.editProfile()
    }
    
    //MARK: - Deinit
    deinit {
        // print(#function, "ProfileViewController")
    }
}

//MARK: - Profile Protocol
extension ProfileViewController: ProfileProtocol {
    func success(model: UserModel) {
        self.model = model
        configureUserCard(with: model)
    }
    
    func error(error: Error) {}
}

//MARK: - Setup view and constraints and config
private extension ProfileViewController {
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(editButton)
    }
    
    private func setupConstraint() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding / 1.5)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(80)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.width.equalTo(100)
        }
    }
    
    private func configureUserCard(with model: UserModel) {
        userCard.configure(with: model)
        view.addSubview(userCard)
        userCard.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

