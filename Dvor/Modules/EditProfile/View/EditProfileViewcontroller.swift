
import UIKit


final class EditProfileViewController: UIViewController {
    
    var presenter: EditProfilePresenter?
    
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    private let titleLabel = UILabel.init(text: "common.editProfile".loc, font: .poppins(weight: .bold, size: .big), textColor: .black, textAlignment: .center)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
    }
    
    //MARK: - Back Button Tapped
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
}

private extension EditProfileViewController {
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(backButton)
        view.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding / 1.5)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(80)
        }
    }
}

extension EditProfileViewController: EditProfileProtocol {
    func success() {}
    func error(error: Error) {}
}
