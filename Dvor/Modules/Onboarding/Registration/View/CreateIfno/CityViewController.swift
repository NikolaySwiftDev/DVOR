import UIKit
import MapKit

final class CityViewController: BaseRegistrationViewController {
    
    private var city = "" {
        didSet { configureEnadle(checkValidButton()) }
    }
    var onNext: ((String) -> Void)?
    
    private let cityTextField: AuthTextFieldView = {
        let tf = AuthTextFieldView(placeholder: "Enter yout city")
        tf.textField.autocorrectionType = .no
        tf.textField.returnKeyType = .done
        return tf
    }()
    
    private let suggestionsTableView: UITableView = {
        let tv = UITableView()
        tv.isHidden = true
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        return tv
    }()
    
    private lazy var completer: MKLocalSearchCompleter = {
        let c = MKLocalSearchCompleter()
        c.delegate = self
        c.resultTypes = .address
        return c
    }()
    
    private var results: [MKLocalSearchCompletion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configure()
    }
    
    override func nextButtonTapped() {
        onNext?(city)
    }
}

//MARK: - UITextFieldDelegate
extension CityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = (textField.text ?? "") as NSString
        let updated = current.replacingCharacters(in: range, with: string)
        
        city = ""
        
        completer.queryFragment = updated
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

//MARK: - MKLocalSearchCompleterDelegate
extension CityViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results.filter { $0.subtitle.isEmpty == false || $0.title.isEmpty == false }
        suggestionsTableView.isHidden = results.isEmpty
        suggestionsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
        suggestionsTableView.isHidden = true
    }
}

//MARK: - UITableView
extension CityViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = results[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = results[indexPath.row].title
        cityTextField.textField.text = selected
        city = selected
        suggestionsTableView.isHidden = true
        cityTextField.resignFirstResponder()
    }
}

//MARK: - setupLayout + config
extension CityViewController {
    private func setupLayout() {
        view.addSubview(cityTextField)
        view.addSubview(suggestionsTableView)
        
        cityTextField.snp.makeConstraints { make in
            make.top.equalTo(descTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        suggestionsTableView.snp.makeConstraints { make in
            make.top.equalTo(cityTextField.snp.bottom).offset(4)
            make.leading.trailing.equalTo(cityTextField)
            make.height.equalTo(200)
        }
    }
    
    private func configure() {
        cityTextField.textField.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self
    }
    
    private func checkValidButton() -> Bool {
        !city.isEmpty
    }
}
