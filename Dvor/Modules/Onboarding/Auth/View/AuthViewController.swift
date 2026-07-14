//
//
//import UIKit
//
//final class AuthViewController: UIViewController {
//    
//    var presenter: AuthPresenterProtocol?
//    private var heightKeyboard: CGFloat = Constants.Constraint.verticalPadding
//
//    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
//    private let nextButton = UIButton.createStandartButton(title: AuthConstants.continueButton, target: self, action: #selector(nextButtonTapped))
//    private let emailTF = AuthTextFieldView(placeholder: AuthConstants.emailPlaceholder)
//    private let passwordTF = AuthTextFieldView(placeholder: AuthConstants.passwordPlaceholder)
//    private let titleLabel = UILabel(text: AuthConstants.authorizationTitle, font: .poppins(weight: .bold, size: .big))
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//        setupConstraints()
//        setupTextField()
//    }
//}
//
//extension AuthViewController {
//    @objc private func backButtonTapped() {
//        presenter?.popVC()
//    }
//    
//    // MARK: - Next Button Action
//    @objc private func nextButtonTapped() {
//        guard let email = emailTF.textField.text, let password = passwordTF.textField.text else { return }
//        presenter?.signIn(email: email, password: password)
//    }
//    
//    private func setupTextField() {
//        emailTF.textField.delegate = self
//        emailTF.textField.textContentType = .emailAddress
//        emailTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//        
//        passwordTF.textField.delegate = self
//        passwordTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//    }
//    
//    @objc private func textFieldDidChange() {
//        let isValid = validateEmailAndPassword(emailField: emailTF,
//                                               passwordField: passwordTF)
//        configureEnadle(isValid)
//    }
//    
//    // MARK: - Configure Enable Next Button
//    func configureEnadle(_ isEnable: Bool) {
//        setNextButtonState(nextButton, isEnabled: isEnable)
//    }
//}
//
//extension AuthViewController: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        adjustNextButtonBottom(nextButton, in: view, isActiveTF: true, isNumberPad: false)
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        adjustNextButtonBottom(nextButton, in: view, isActiveTF: false)
//    }
//}
//
//extension AuthViewController {
//    private func setupView() {
//        view.backgroundColor = Constants.Colors.backgroungColor
//        
//        configureEnadle(false)
//        
//        view.addSubview(backButton)
//        view.addSubview(titleLabel)
//        view.addSubview(emailTF)
//        view.addSubview(passwordTF)
//        view.addSubview(nextButton)
//        
//    }
//    
//    private func setupConstraints() {
//        backButton.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
//            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
//        }
//        
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(backButton.snp.bottom).offset(Constants.Constraint.verticalPadding)
//            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
//        }
//        
//        emailTF.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding * 2)
//            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
//            make.height.equalTo(Constants.Constraint.buttonHeight)
//        }
//        
//        passwordTF.snp.makeConstraints { make in
//            make.top.equalTo(emailTF.snp.bottom).offset(Constants.Constraint.verticalPadding)
//            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
//            make.height.equalTo(Constants.Constraint.buttonHeight)
//        }
//        
//        nextButton.snp.makeConstraints { make in
//            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(heightKeyboard)
//            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
//            make.height.equalTo(Constants.Constraint.buttonHeight)
//        }
//    }
//}
//
//fileprivate struct AuthConstants {
//    static let continueButton = "auth.continue".loc
//    static let emailPlaceholder = "auth.email".loc
//    static let passwordPlaceholder = "auth.password".loc
//    static let authorizationTitle = "auth.authorization".loc
//}
