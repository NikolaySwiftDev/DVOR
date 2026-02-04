

import UIKit

final class AuthViewController: UIViewController {
    
    var presenter: AuthPresenterProtocol?
    private var heightKeyboard: CGFloat = Constants.Constraint.verticalPadding

    
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    private let nextButton = UIButton.createStandartButton(title: "Продолжить", target: self, action: #selector(nextButtonTapped))
    private let emailTF = AuthTextFieldView(placeholder: "Почта")
    private let passwordTF = AuthTextFieldView(placeholder: "Пароль")
    private let titleLabel = UILabel(text: "Авторизация", font: .poppins(weight: .bold, size: .big))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupTextField()
    }
}

extension AuthViewController {
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    // MARK: - Next Button Action
    @objc private func nextButtonTapped() {
        guard let email = emailTF.textField.text, let password = passwordTF.textField.text else { return }
        presenter?.signIn(email: email, password: password)
    }
    
    private func setupTextField() {
        emailTF.textField.delegate = self
        emailTF.textField.textContentType = .emailAddress
        emailTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        passwordTF.textField.delegate = self
        passwordTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let email = emailTF.textField.text ?? ""
        let password = passwordTF.textField.text ?? ""
        
        let isEmailValid = email.isValidEmail()
        let isPasswordValid = password.count >= 6
        
        
        isEmailValid ? emailTF.updateBorderColor() : emailTF.updateBorderColor(.clear)
        isPasswordValid ? passwordTF.updateBorderColor() : passwordTF.updateBorderColor(.clear)

        configureEnadle(isEmailValid && isPasswordValid)
    }
    
    // MARK: - Configure Enable Next Buttom
    func configureEnadle(_ isEnable: Bool) {
        nextButton.backgroundColor = isEnable ? Constants.Colors.buttonActiveColor : Constants.Colors.buttonInActiveColor
        nextButton.isEnabled = isEnable
    }
    
    // MARK: - Configure Bottom Padding Next Buttom
    func configureBottomPaddingButtom(isActiveTF: Bool, isNumberPad: Bool = true) {
        let newInset =  isActiveTF ?
                        isNumberPad ? BaseConstants.bottomPaddingNumberPad
                                    : BaseConstants.bottomPaddingKeyboard : Constants.Constraint.horizPadding
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
            self.nextButton.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(newInset)
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension AuthViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: true, isNumberPad: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: false)
    }
}

extension AuthViewController {
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        
        configureEnadle(false)
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(emailTF)
        view.addSubview(passwordTF)
        view.addSubview(nextButton)
        
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
            make.size.equalTo(24)
        }
        
       titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        emailTF.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding * 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        passwordTF.snp.makeConstraints { make in
            make.top.equalTo(emailTF.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(heightKeyboard)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
}

fileprivate struct BaseConstants {
    static let bottomPaddingNumberPad: CGFloat = (UIScreen.main.bounds.height / 3)
    static let bottomPaddingKeyboard: CGFloat = (UIScreen.main.bounds.height / 2.7)
    static let progressHeight: CGFloat = 4
    static let backButtonSize: CGFloat = 24

}
