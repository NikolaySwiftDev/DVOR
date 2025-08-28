

import UIKit

final class PhoneConfirmViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: (() -> Void)?
    
    private var code = ""
    private var phone = ""
    private var countdownTimer: Timer?
    private var remainingSeconds = 120

    //MARK: - UI
    private let codeField = AuthTextFieldView(placeholder: "Введите код")
    private let numberLabel = UILabel(font: .poppins(weight: .regular, size: .mid), textAlignment: .center)
    private let repeatCodeLabel = UILabel(text: "Отправить снова через 120 секунд", font: .poppins(weight: .regular, size: .mid), textAlignment: .center)
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupTextField()
        presenter?.makeCodeRequest(with: phone)
    }
    
    //MARK: - Start Timer 
    private func startCountdown() {
        remainingSeconds = 120
        updateRepeatLabel()
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(
               withTimeInterval: 1,
               repeats: true
           ) { [weak self] _ in
               self?.updateCountdown()
           }
    }

    //MARK: - Update Countdown
    @objc private func updateCountdown() {
        remainingSeconds -= 1
        updateRepeatLabel()
        
        if remainingSeconds <= 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }

    //MARK: - Update Repeat Label
    private func updateRepeatLabel() {
        if remainingSeconds > 0 {
            repeatCodeLabel.text = "Отправить снова через \(remainingSeconds) секунд"
            repeatCodeLabel.isUserInteractionEnabled = false
        } else {
            repeatCodeLabel.text = "Отправить снова"
            repeatCodeLabel.isUserInteractionEnabled = true
        }
    }

    //MARK: - Setup Layout
    private func setupLayout() {
        view.addSubview(numberLabel)
        view.addSubview(codeField)
        view.addSubview(repeatCodeLabel)
        
        repeatCodeLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(repaetButtonTapped))
        repeatCodeLabel.addGestureRecognizer(tapGesture)
        
        numberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-120)
        }
        
        codeField.snp.makeConstraints { make in
            make.top.equalTo(numberLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        repeatCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(codeField.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
    }
    
    //MARK: - Set Title With Number
    func setTitleNumberText(with text: String) {
        phone = text
        numberLabel.text = "Код отправлен на номер \n \(phone.formattedAsRussianPhone())"
    }
    
    //MARK: - Setup Text Field
    private func setupTextField() {
        codeField.textField.delegate = self
        codeField.textField.keyboardType = .numberPad
        codeField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        checkValidCode()
    }
    
    //MARK: - Check Valid Code
    private func checkValidCode() {
        guard let text = codeField.textField.text else { return }
        
        let isValid = text.count > 4
        configureEnadle(isValid)
        code = text
        
        text.count == 0 ? codeField.updateBorderColor(.clear) : codeField.updateBorderColor()
    }

    //MARK: -Next Button Action
    override func nextButtonTapped() {
        presenter?.makePhoneRequest(with: code)
    }
    
    //MARK: - Repaet Button Action
    @objc private func repaetButtonTapped() {
        guard remainingSeconds <= 0 else { return }
        presenter?.makeCodeRequest(with: phone)
    }

    deinit {
        print("Deinit ---- PhoneConfirmViewController")
    }
}

    //MARK: - Regist Protocol
extension PhoneConfirmViewController:  RegistProtocol {
    func updateTFText(_ code: String) {
        self.code = code
        codeField.textField.text = code
        
        checkValidCode()
    }
    
    func updateAvatarImage(_ image: UIImage) {}
    
    func showError(_ message: String) {
        print("Error --- ", message)
        code = ""
        codeField.textField.text = ""
        checkValidCode()
    }
    
    func showSuccess() {
        onNext?()
    }
    
    func showLoading() {
        startCountdown()
    }
    
    func hideLoading() {
        print(#function)
    }
}

//MARK: - UITextFieldDelegate
extension PhoneConfirmViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Разрешаем только цифры и backspace
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet) || string.isEmpty
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: false)
    }
}
