
import UIKit
import SnapKit

final class AuthViewController: UIViewController {

    //MARK: - Properties
    var presenter: AuthPresenterProtocol?
    
    private let backgroungImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(resource: .onboard)
        return view
    }()
        
    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Пропустить", for: .normal)
        btn.setTitleColor(.white, for: .normal) // Временный явный цвет
        btn.titleLabel?.font = UIFont.poppins(weight: .semiBold, size: .small)
        btn.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return btn
    }()

    private let enterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Войти", for: .normal)
        btn.setTitleColor(Constants.Colors.titleColor, for: .normal)
        btn.backgroundColor = Constants.Colors.buttonActiveColor
        btn.layer.cornerRadius = Constants.cornerRadius
        btn.titleLabel?.font = UIFont.poppins(weight: .semiBold, size: .small)
        btn.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContraints()
    }
    
    //MARK: - Skip Button Tapped
    @objc private func skipButtonTapped() {
        presenter?.pushMainView()
    }

    //MARK: - Enter Button Tapped
    @objc private func enterButtonTapped() {
        presenter?.pushRegistVC()
    }
}

//MARK: - AuthProtocol
extension AuthViewController: AuthProtocol {}

//MARK: - Extension SetupView and SetupContraints
private extension AuthViewController {
    private func setupView() {
        
        view.addSubview(backgroungImage)
        view.addSubview(skipButton)
        view.addSubview(enterButton)
    }
    
    private func setupContraints() {
        backgroungImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        skipButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().inset(Constants.horizPadding)
            make.height.equalTo(Constants.buttonHeight)
            make.width.equalTo(Constants.buttonHeight * 2)
        }
        
        enterButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(AuthConstants.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.horizPadding)
            make.height.equalTo(Constants.buttonHeight)
        }
    }
}

fileprivate struct AuthConstants {
    static let verticalPadding: CGFloat = 20
}
