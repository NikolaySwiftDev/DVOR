import UIKit

final class CityViewController: BaseRegistrationViewController {
    
    private var city: CityModel? {
        didSet {
            configureEnadle(city != nil)
        }
    }
    
    var onNext: ((CityModel) -> Void)?
    var isEdit: Bool = false
    
    private let cityTextField = CustomTextFieldView(placeholder: "cityview.placeholder".loc)
    private let suggestionsView = CitySuggestionsView()
    private let geoButton = UIButton.createStandartButton(title: "Geo".loc, titleColor: .black)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configure()
    }
    
    override func nextButtonTapped() {
        guard let city = city else { return }
        if isEdit {
            presenter?.updateCity(city: city)
        } else {
            onNext?(city)
        }
    }
    
    @objc private func geoButtonTapped() {
        cityTextField.resignFirstResponder()
        geoButton.isEnabled = false
        
        presenter?.requestCurrentCity { [weak self] city in
            guard let self else { return }
            self.geoButton.isEnabled = true
            
            guard let city else {
                return
            }
            
            self.cityTextField.textField.text = city.name
            self.suggestionsView.clear()
            self.city = city
        }
    }
    
    deinit {
        isEdit = false
//        print("Deinit CityViewController")
    }
    
}

//MARK: - UITextFieldDelegate
extension CityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = (textField.text ?? "") as NSString
        let updated = current.replacingCharacters(in: range, with: string)
        
        city = nil
        suggestionsView.search(query: updated)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - setupLayout + config
extension CityViewController {
    private func setupLayout() {
        view.addSubview(cityTextField)
        view.addSubview(geoButton)
        view.addSubview(suggestionsView)
        
        cityTextField.snp.makeConstraints { make in
            make.top.equalTo(descTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.trailing.equalTo(geoButton.snp.leading).offset(-8)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        geoButton.snp.makeConstraints { make in
            make.centerY.equalTo(cityTextField)
            make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.size.equalTo(Constants.Constraint.buttonHeight)
        }
        
        suggestionsView.snp.makeConstraints { make in
            make.top.equalTo(cityTextField.snp.bottom).offset(4)
            make.leading.trailing.equalTo(cityTextField)
            make.height.equalTo(200)
        }
    }
    
    private func configure() {
        cityTextField.textField.delegate = self
        geoButton.addTarget(self, action: #selector(geoButtonTapped), for: .touchUpInside)
        
        suggestionsView.onCitySelected = { [weak self] locality in
            guard let self else { return }
            self.cityTextField.textField.text = locality.name
            self.city = locality
            self.cityTextField.resignFirstResponder()
        }
        
        suggestionsView.onInvalidSelection = { [weak self] in
            self?.city = nil
        }
    }
}
