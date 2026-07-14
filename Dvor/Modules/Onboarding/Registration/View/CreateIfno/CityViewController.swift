import UIKit

final class CityViewController: BaseRegistrationViewController {
    
    private var city = "" {
        didSet { configureEnadle(checkValidButton()) }
    }
    var onNext: ((String) -> Void)?
    
    private let cityTextField = AuthTextFieldView(placeholder: "cityview.placeholder".loc)
    private let suggestionsView = CitySuggestionsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configure()
    }
    
    override func nextButtonTapped() {
        onNext?(city)
    }
    
    deinit {
        print("Deinit City VC")
    }
}

//MARK: - UITextFieldDelegate
extension CityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = (textField.text ?? "") as NSString
        let updated = current.replacingCharacters(in: range, with: string)
        
        city = ""
        suggestionsView.search(query: updated)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: true, isNumberPad: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        configureBottomPaddingButtom(isActiveTF: false)
    }
    

}

//MARK: - setupLayout + config
extension CityViewController {
    private func setupLayout() {
        view.addSubview(cityTextField)
        view.addSubview(suggestionsView)
        
        cityTextField.snp.makeConstraints { make in
            make.top.equalTo(descTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        suggestionsView.snp.makeConstraints { make in
            make.top.equalTo(cityTextField.snp.bottom).offset(4)
            make.leading.trailing.equalTo(cityTextField)
            make.height.equalTo(200)
        }
    }
    
    private func configure() {
        cityTextField.textField.delegate = self
        
        suggestionsView.onCitySelected = { [weak self] locality in
            guard let self else { return }
            self.cityTextField.textField.text = locality
            self.city = locality
            self.cityTextField.resignFirstResponder()
        }
        
        suggestionsView.onInvalidSelection = { [weak self] in
            self?.city = ""
        }
    }
    
    private func checkValidButton() -> Bool {
        !city.isEmpty
    }
}
