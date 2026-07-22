import UIKit

final class InfoInputViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: ((String, String, Date?) -> Void)?
    private var name = ""
    private var surname = ""
    private var dateBD: Date? = nil
    
    //MARK: - UI
    private let nameTF = AuthTextFieldView(placeholder: "infoInput.nikname".loc)

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        config()
    }

    //MARK: - Next Button Action
    override func nextButtonTapped() {
        guard name != "" else { return }
        onNext?(name, surname, dateBD)
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard name != "" else { return false }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


private extension InfoInputViewController {
    
    //MARK: - Config TF
    private func config() {
        nameTF.textField.delegate = self
        nameTF.textField.tag = 0
        nameTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        switch textField.tag {
        case 0:
            name = text
            configureEnadle(checkValidButton())
            checkCountTFIsNotEmpty(text: text, tf: nameTF)
            
        default:
            break
        }
    }
    
    //MARK: - Setup Layout
    private func setupLayout() {
        
        let nameView = createTFView(text: "infoInput.nikname".loc, tf: nameTF)
        
        let stack = UIStackView(arrangedSubviews: [nameView/*, surnameView*/])
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
    }
}
