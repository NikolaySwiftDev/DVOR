import UIKit

final class InfoInputViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: ((String, String, Date) -> Void)?
    private var name = ""
    private var surname = ""
    private var dateBD: Date? = nil
    
    //MARK: - UI
    private let nameTF = AuthTextFieldView(placeholder: "Имя")
    private let surnameTF = AuthTextFieldView(placeholder: "Фамилия")
    private let dateTF = AuthTextFieldView(placeholder: "ДД/ММ/ГГГГ")

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        config()
    }

    //MARK: - Next Button Action
    override func nextButtonTapped() {
        guard name != "", surname != "", let date = dateBD else { return }
        print(date)
        onNext?(name, surname, date)
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard name != "", surname != "",  dateBD != nil else { return false }
        return true
    }
}

//MARK: - UITextFieldDelegate
extension InfoInputViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            guard allowedCharacters.isSuperset(of: characterSet) || string.isEmpty else {
                return false
            }
            
            let cleanString = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return cleanString.count <= 8
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0,1:
            configureBottomPaddingButtom(isActiveTF: true, isNumberPad: false)
        default:
            configureBottomPaddingButtom(isActiveTF: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: false)
    }
}


private extension InfoInputViewController {
    
    //MARK: - Config TF
    private func config() {
        nameTF.textField.delegate = self
        nameTF.textField.tag = 0
        nameTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        surnameTF.textField.delegate = self
        surnameTF.textField.tag = 1
        surnameTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        dateTF.textField.delegate = self
        dateTF.textField.tag = 2
        dateTF.textField.keyboardType = .numberPad
        dateTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        switch textField.tag {
        case 0:
            name = text
            configureEnadle(checkValidButton())
            checkTFIsNotEmpty(text: text, tf: nameTF)
        case 1:
            surname = text
            configureEnadle(checkValidButton())
            checkTFIsNotEmpty(text: text, tf: surnameTF)
        case 2:
            let formattedText = text.formattedAsBirthDate()
            if textField.text != formattedText {
                textField.text = formattedText
            }
            
            if formattedText.count == 10 {
                parseBirthDate(formattedText)
            } else {
                dateBD = nil
            }
            
            configureEnadle(checkValidButton())
            checkTFIsNotEmpty(text: formattedText, tf: dateTF)
            
        default:
            break
        }
    }
    
    //MARK: - Setup Layout
    private func setupLayout() {
        
        let nameView = createTFView(text: "Имя", tf: nameTF)
        let surnameView = createTFView(text: "Фамилия", tf: surnameTF)
        let dateBDView = createTFView(text: "Дата рождения", tf: dateTF)
        
        let stack = UIStackView(arrangedSubviews: [nameView, surnameView])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.alignment = .fill

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(descTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight * 2)
        }
        
        view.addSubview(dateBDView)
        dateBDView.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight * 2)
        }
    }
    
    //MARK: - Parse Birth Date from string
    private func parseBirthDate(_ dateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        
        guard let date = formatter.date(from: dateString) else {
            dateTF.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if date.isAdult() {
            dateBD = date
            dateTF.layer.borderColor = Constants.Colors.layerColor.cgColor
        } else {
            dateTF.layer.borderColor = UIColor.red.cgColor
        }
    }
}
