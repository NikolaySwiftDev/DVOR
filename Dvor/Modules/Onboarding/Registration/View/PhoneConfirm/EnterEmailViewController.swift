
import UIKit

final class EnterEmailViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: ((String) -> Void)?
    var pushCreateInfo: (() -> Void)?


    //MARK: - UI
    private let emailTF = AuthTextFieldView(placeholder: "dvor@gmail.com")
    private let passwordTF = AuthTextFieldView(placeholder: "Минимум 6 символов")
    
    private let descEmailLabel = UILabel(text: "Почта", font: .poppins(weight: .medium, size: .small))
    private let descPasswodLabel = UILabel(text: "Пароль", font: .poppins(weight: .medium, size: .small))
    
    private var email = ""
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupTextField()
    }
    
    //MARK: - Setup Layout
    private func setupLayout() {
        view.backgroundColor = Constants.Colors.backgroungColor
        
        view.addSubview(emailTF)
        view.addSubview(descEmailLabel)
        
        view.addSubview(passwordTF)
        view.addSubview(descPasswodLabel)
        
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

    //MARK: - Setup Text Field
    private func setupTextField() {
        emailTF.textField.delegate = self
        emailTF.textField.textContentType = .emailAddress
        emailTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        passwordTF.textField.delegate = self
        passwordTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let isValid = validateEmailAndPassword(emailField: emailTF,
                                               passwordField: passwordTF)
        configureEnadle(isValid)
    }
    
    
    override func nextButtonTapped() {
        guard
            let email = emailTF.textField.text, email.isValidEmail(),
            let password = passwordTF.textField.text, password.count >= 6
        else { return }
        
        self.email = email
        presenter?.signUp(email: email, password: password)
    }

    
    deinit {
        print("Deinit ---- EnterEmailViewController")
    }
}

//MARK: - UITextFieldDelegate
extension EnterEmailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: true, isNumberPad: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: false)
    }
}

extension EnterEmailViewController: RegistProtocol {
    func updateAvatarImage(_ image: UIImage) {}
    
    func showInfoInput() {
        pushCreateInfo?()
    }

    func showError(_ message: String) {
        emailTF.textField.text = ""
        passwordTF.textField.text = ""
        
        emailTF.updateBorderColor(.clear)
        passwordTF.updateBorderColor(.clear)
    }
    
    func showSuccess() {
        onNext?(email)
    }
        
    func showLoading() {
        hideLoadingView(with: view, tag: 120, state: .add)
        
    }

    func hideLoading() {
        hideLoadingView(with: view, tag: 120, state: .delete)
    }
}
