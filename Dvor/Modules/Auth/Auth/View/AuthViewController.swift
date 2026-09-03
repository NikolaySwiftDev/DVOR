import UIKit

final class AuthViewController: UIViewController {
    
    var presenter: AuthPresenterProtocol?
    private var heightKeyboard: CGFloat = Constants.Constraint.verticalPadding
    private var email = ""
    private var password = ""
    
    // MARK: - UI
    
    private let backButton = UIButton.createBackButton(
        target: self,
        action: #selector(backButtonTapped)
    )
    
    private let nextButton = UIButton.createStandartButton(
        title: AuthConstants.continueButton,
        target: self,
        action: #selector(nextButtonTapped)
    )
    
    private let emailTF = CustomTextFieldView(
        placeholder: AuthConstants.emailPlaceholder,
        type: .email
    )
    
    private let passwordTF = CustomTextFieldView(
        placeholder: AuthConstants.passwordPlaceholder,
        type: .password
    )
    
    private let titleLabel = UILabel(
        text: AuthConstants.title,
        font: .poppins(weight: .bold, size: .big)
    )
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        setupTextField()
    }
}

// MARK: - Actions

extension AuthViewController {
    
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    @objc private func nextButtonTapped() {
        presenter?.signIn(email: email, password: password)
    }
}

// MARK: - Text Fields

extension AuthViewController {
    
    private func setupTextField() {
        emailTF.textField.delegate = self
        emailTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        passwordTF.textField.delegate = self
        passwordTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
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
    
    // MARK: - Configure Enable Next Button
    
    private func configureEnadle(_ isEnable: Bool) {
        setNextButtonState(nextButton,isEnabled: isEnable)
    }
    
    private func checkValidButton() -> Bool {
        email.isValidEmail && password.count >= 6
    }
}

// MARK: - UITextFieldDelegate

extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Setup

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
            make.top.equalTo(view.safeAreaLayoutGuide)
                .offset(Constants.Constraint.verticalPadding)
            
            make.leading.equalToSuperview()
                .offset(Constants.Constraint.horizPadding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom)
                .offset(Constants.Constraint.verticalPadding)
            
            make.leading.trailing.equalToSuperview()
                .inset(Constants.Constraint.horizPadding)
        }
        
        emailTF.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
                .offset(Constants.Constraint.verticalPadding * 2)
            
            make.leading.trailing.equalToSuperview()
                .inset(Constants.Constraint.horizPadding)
            
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        passwordTF.snp.makeConstraints { make in
            make.top.equalTo(emailTF.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            let constraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.Constraint.verticalPadding).constraint
            observeKeyboard(for: constraint)
            $0.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
}
