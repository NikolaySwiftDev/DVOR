
import UIKit

final class EnterPhoneViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: ((String) -> Void)?

    //MARK: - UI
    private let phoneTF = AuthTextFieldView(placeholder: "+7 (XXX) XXX-XX-XX")
    private let descNumberLabel = UILabel(text: "Номер телефона", font: .poppins(weight: .medium, size: .small))
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupTextField()
    }
    
    //MARK: - Setup Layout
    private func setupLayout() {
        view.backgroundColor = Constants.Colors.backgroungColor
        
        view.addSubview(phoneTF)
        view.addSubview(descNumberLabel)

        
        descNumberLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-100)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        phoneTF.snp.makeConstraints { make in
            make.top.equalTo(descNumberLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }

    //MARK: - Setup Text Field
    private func setupTextField() {
        phoneTF.textField.delegate = self
        phoneTF.textField.keyboardType = .numberPad
        phoneTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        formatPhoneNumber()
    }
    
    //MARK: - Format phone number from TF and check Valid
    private func formatPhoneNumber() {
        guard let text = phoneTF.textField.text else { return }
        
        phoneTF.textField.layer.borderColor = UIColor.red.cgColor
        
        let cleanNumber = text.cleanedPhoneNumber()
        
        if cleanNumber.count > 11 {
            let index = cleanNumber.index(cleanNumber.startIndex, offsetBy: 11)
            let trimmed = String(cleanNumber[..<index])
            phoneTF.textField.text = trimmed.formattedAsRussianPhone()
            return
        }
        
        phoneTF.textField.text = text.formattedAsRussianPhone()
        
        let isValid = cleanNumber.isValidRussianPhone()
        configureEnadle(isValid)

    }

    
    override func nextButtonTapped() {
        guard let phone = phoneTF.textField.text else { return }
        let cleanNumber = phone.cleanedPhoneNumber()
        print(cleanNumber)
        onNext?(cleanNumber)
    }
    
    deinit {
        print("Deinit ---- EnterPhoneViewController")
    }
}

//MARK: - UITextFieldDelegate
extension EnterPhoneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Разрешаем только цифры и backspace
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet) || string.isEmpty
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: true)
        if textField.text?.isEmpty ?? true {
            textField.text = "+7 "
            phoneTF.updateBorderColor()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: false)
    }
}
