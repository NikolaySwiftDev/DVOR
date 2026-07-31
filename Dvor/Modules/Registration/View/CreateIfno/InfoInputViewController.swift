import UIKit

final class InfoInputViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    var onNext: ((String) -> Void)?
    private var nickname = ""
    var isEdit: Bool = false
    
    //MARK: - UI
    private let nameTF = CustomTextFieldView(placeholder: "infoInput.nikname".loc)

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        config()
    }

    //MARK: - Next Button Action
    override func nextButtonTapped() {
        guard nickname != "" else { return }
        if isEdit {
            presenter?.updateNickname(nickname: nickname)
        } else {
            onNext?(nickname)
        }
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard nickname != "" else { return false }
        return true
    }
    
    deinit {
        isEdit = false
        print("Deinit CreateAvatarViewController")
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
            nickname = text
            configureEnadle(checkValidButton())
            checkCountTFIsNotEmpty(text: text, tf: nameTF)
            
        default:
            break
        }
    }
    
    //MARK: - Setup Layout
    private func setupLayout() {
        
        let nameView = createTFView(text: "infoInput.nikname".loc, tf: nameTF)
        
        let stack = UIStackView(arrangedSubviews: [nameView])
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
