import UIKit

final class EnterEmailViewController: BaseRegistrationViewController {

    // MARK: - Properties

    var onNext: ((String) -> Void)?

    private var email = ""
    private var password = ""

    // MARK: - UI

    private let emailTF = CustomTextFieldView(
        placeholder: EnterEmailConstants.emailTF,
        type: .email
    )

    private let passwordTF = CustomTextFieldView(
        placeholder: EnterEmailConstants.passwordTF,
        type: .password
    )

    private let descEmailLabel = UILabel(
        text: EnterEmailConstants.descEmailLabel,
        font: .poppins(weight: .medium, size: .small)
    )

    private let descPasswodLabel = UILabel(
        text: EnterEmailConstants.descPasswodLabel,
        font: .poppins(weight: .medium, size: .small)
    )
    

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
        emailTF.textField.delegate = self
        emailTF.textField.addTarget(self,action: #selector(textFieldDidChange),for: .editingChanged)
    }

    private func setupPasswordTextField() {
        passwordTF.textField.delegate = self
        passwordTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

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
        presenter?.signUp(email: email, password: password)
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
        
    }
}
    
extension EnterEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension EnterEmailViewController: RegistProtocol {
    func showError(_ message: String) {
        print(message)
    }
    
    func showSuccess() {
        onNext?(email)
    }
    
    func showLoading() {
        hideLoadingView(with: view, tag: 67, state: .add)
    }
    
    func hideLoading() {
        hideLoadingView(with: view, tag: 67, state: .delete)
    }
    
    func updateAvatarImage(_ image: UIImage) {}
}

fileprivate struct EnterEmailConstants {
    static let emailTF = "dvor@gmail.com"
    static let passwordTF = "enter_email.password_placeholder".loc
    static let descEmailLabel = "enter_email.email_description".loc
    static let descPasswodLabel = "enter_email.password_description".loc
}


