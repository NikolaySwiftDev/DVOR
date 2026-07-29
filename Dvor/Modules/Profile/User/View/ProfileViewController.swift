
import UIKit
final class ProfileViewController: UIViewController {
    
    var presenter: ProfilePresenterProtocol?
    var model: UserModel?
    
    private let isOwnProfile: Bool

    private let titleLabel = UILabel.init(text: ProfileViewConstants.title, font: .poppins(weight: .bold, size: .big), textColor: .black, textAlignment: .center)
    private let userCard = UserCardView()
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    private let editButton = UIButton.createStandartButton(title: ProfileViewConstants.editButton, backgroundColor: .black,cornerRadius: 8, target: self, action: #selector(editButtonTapped))
    private let deleteButton = UIButton.createStandartButton(title: ProfileViewConstants.deleteButton, backgroundColor: .black, target: self, action: #selector(deleteButtonTapped))

    init(model: UserModel? = nil) {
        self.model = model
        self.isOwnProfile = (model == nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
    }
    
    //MARK: - Loading
    private func loadProfile() {
        if isOwnProfile {
            presenter?.getProfileInto()
        } else if let model = model {
            configureUserCard(with: model)
        }
    }
    
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    @objc private func editButtonTapped() {
        guard isOwnProfile else { return }
        presenter?.editProfile()
    }
    
    @objc private func deleteButtonTapped() {
        guard isOwnProfile else { return }
        presenter?.deleteProfile()
    }
    
    deinit {
//         print(#function, "ProfileViewController")
    }
}

extension ProfileViewController: ProfileProtocol {
    func success(model: UserModel) {
        self.model = model
        configureUserCard(with: model)
    }
    
    func error(error: Error) {}
}

private extension ProfileViewController {
    private func setupView() {
        editButton.isHidden = !isOwnProfile
        deleteButton.isHidden = !isOwnProfile
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(userCard)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(editButton)
        view.addSubview(deleteButton)
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
            make.width.equalTo(ProfileViewConstants.buttonSize)
        }
        
        userCard.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(ProfileViewConstants.horizPadding)
            make.leading.trailing.equalToSuperview()
            if isOwnProfile {
                make.bottom.equalTo(deleteButton.snp.top).offset(-Constants.Constraint.horizPadding)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        deleteButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding * 1.5)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
    
    private func configureUserCard(with model: UserModel) {
        userCard.configure(with: model)

    }
}
 
