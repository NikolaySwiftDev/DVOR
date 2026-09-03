import UIKit

final class EnterEmailViewController: BaseRegistrationViewController {

    // MARK: - Properties

    var onNext: ((String, String) -> Void)?

    private var email = ""
    private var password = ""

    // MARK: - UI

    private let emailTF = CustomTextFieldView(
        placeholder: "dvor@gmail.com"
    )

    private let passwordTF = CustomTextFieldView(
        placeholder: "Минимум 6 символов"
    )

    private let descEmailLabel = UILabel(
        text: "Почта",
        font: .poppins(weight: .medium, size: .small)
    )

    private let descPasswodLabel = UILabel(
        text: "Пароль",
        font: .poppins(weight: .medium, size: .small)
    )
    
    private let togglePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .darkGray
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        return button
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupTextFields()
    }

    // MARK: - Setup Text Fields
    private func setupTextFields() {
        setupEmailTextField()
        setupPasswordTextField()
    }

    private func setupEmailTextField() {
        let textField = emailTF.textField

        textField.delegate = self
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        textField.addTarget(self,action: #selector(textFieldDidChange),for: .editingChanged)
    }

    private func setupPasswordTextField() {
        let textField = passwordTF.textField

        textField.delegate = self
        textField.textContentType = .newPassword
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility() {
        let textField = passwordTF.textField
        textField.isSecureTextEntry.toggle()

        if let existingText = textField.text {
            textField.text = nil
            textField.text = existingText
        }

        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        togglePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Actions

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }

        if textField === emailTF.textField {
            email = text
            checkEmailTFisValid(text: text,tf: emailTF)
            
        } else if textField === passwordTF.textField {
            password = text
            checkPasswordTFIsNotEmpty(text: text, tf: passwordTF)
        }

        configureEnadle(checkValidButton())
    }

    // MARK: - Validation

    private func checkValidButton() -> Bool {
        email.isValidEmail && password.count >= 6
    }

    // MARK: - Next

    override func nextButtonTapped() {
        guard checkValidButton() else {
            return
        }

        onNext?(email, password)
    }

    // MARK: - Deinit

    deinit {
        print("Deinit ---- EnterEmailViewController")
    }
}

// MARK: - UITextFieldDelegate

private extension EnterEmailViewController {
    // MARK: - Setup Layout
    private func setupLayout() {
        view.backgroundColor = Constants.Colors.backgroungColor

        view.addSubview(descEmailLabel)
        view.addSubview(emailTF)
        view.addSubview(descPasswodLabel)
        view.addSubview(passwordTF)
        passwordTF.addSubview(togglePasswordButton)

        descEmailLabel.snp.makeConstraints { make in
            make.top.equalTo(descTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

        emailTF.snp.makeConstraints { make in
            make.top.equalTo(descEmailLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }

        descPasswodLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTF.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

        passwordTF.snp.makeConstraints { make in
            make.top.equalTo(descPasswodLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        togglePasswordButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(22)
            make.width.equalTo(31)
        }
    }
}
    
extension EnterEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



