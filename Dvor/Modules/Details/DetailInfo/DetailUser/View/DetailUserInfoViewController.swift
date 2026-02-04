
import UIKit

final class DetailUserInfoViewController: UIViewController {
    
    var presenter: DetailUserInfoPresenterProtocol?

    //MARK: - Model
    private var model: UserModel

    //MARK: - Properties
    private let card = UserCardView()
    private let profile = UserProfileView()
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    
    //MARK: - Init
    init(model: UserModel) {
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
        configure()
        setupConstraints()
    }
    
    //MARK: - Func
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    //MARK: - Deinit
    deinit {
        print("Deinit DetailUserInfoViewController")
    }
}

//MARK: - Detail User Info Protocol
extension DetailUserInfoViewController: DetailUserInfoProtocol {}

//MARK: - Setup, config
private extension DetailUserInfoViewController {
    private func setupView() {
        view.backgroundColor = DetailUserInfoConstants.backColor
        view.addSubview(backButton)
        view.addSubview(card)
        view.addSubview(profile)
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(DetailUserInfoConstants.paddingStandart)
//            make.size.equalTo(DetailUserInfoConstants.heightBackBtn)
        }
        
        card.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(350)
            make.width.equalTo(300)
        }
            
        profile.snp.makeConstraints { make in
            make.top.equalTo(card.snp.bottom).offset(DetailUserInfoConstants.paddingStandart)
            make.centerX.equalToSuperview()
            make.height.equalTo(170)
            make.width.equalTo(DetailUserInfoConstants.widthScreen - 20)
        }
    }
    
    private func configure() {
        card.configure(with: model)
        profile.configure(with: model)
        profile.delegate = self
    }
}

//MARK: - User Profil eView Delegate follow
extension DetailUserInfoViewController: UserProfileViewDelegate {
    func followButtonDidTap() {
        presenter?.followUser()
    }
}

fileprivate struct DetailUserInfoConstants {
    static let backColor: UIColor = .backgrDarkGreen
    static let cornerRadius: CGFloat = 10
    static let paddingStandart: CGFloat = 20
    static let heightBackBtn: CGFloat = 40
    static let widthScreen: CGFloat = UIScreen.main.bounds.width
}

