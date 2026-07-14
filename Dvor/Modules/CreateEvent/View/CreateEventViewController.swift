

import UIKit

final class CreateEventViewController: UIViewController {
    
    var presenter: CreateEventPresenterProtocol?
    private var date: Date
    private var player = 0
    private var time = ""
    private var adress = "" {
        didSet { updateValidButton() }
    }
    private var place = ""
        
    private let navigationBar = SupportNavigationBar(state: .createEvent)
    private let subTitle = UILabel(text: CreateEventConstants.enterData)
    private let titleDate = UILabel.init(font: .poppins(weight: .regular, size: .small), textAlignment: .center)
    private let adressTF = AuthTextFieldView(placeholder: CreateEventConstants.addressPlaceholder)
    private let playersTF = AuthTextFieldView(placeholder: CreateEventConstants.playersPlaceholder)
    private let timeTF = AuthTextFieldView(placeholder: CreateEventConstants.timePlaceholder)
    private let placeTF = AuthTextFieldView(placeholder: CreateEventConstants.placePlaceholder)
    private let nextButton = UIButton.createStandartButton(title: CreateEventConstants.createButton, target: self, action: #selector(nextButtonTapped))
    
    private lazy var addressSuggestionsView = AddressSuggestionsView()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.minimumDate = Date()
        picker.maximumDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        picker.isHidden = true
        picker.backgroundColor = Constants.Colors.backgroungColor
        return picker
    }()
    
    init(date: Date) {
        self.date = date
        titleDate.text = "\(CreateEventConstants.eventDate) \(date.toString())"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        config()
        
        presenter?.getCityForSearchAdress()
    }
    
    @objc private func nextButtonTapped() {
        presenter?.writeEvent(players: player, date: date, time: time, address: adress, place: place)
    }
    
    private func updateValidButton() {
        nextButton.backgroundColor = checkValidButton() ? Constants.Colors.buttonActiveColor : Constants.Colors.buttonInActiveColor
        nextButton.isEnabled = checkValidButton()
    }
    
    deinit {
        print("deinit CreateEventViewController")
    }
}

//MARK: - Create Event Protocol
extension CreateEventViewController: CreateEventProtocol {
    func success(city: String) {
        addressSuggestionsView.expectedCity = city
        print("City is success --- " + city)
    }
    func error(error: Error) {}
}

//MARK: - Navigation Bar Delegate
extension CreateEventViewController: SupportNavigationBarDelegate {
    func backButtonTapped() {
        presenter?.popVC()
    }
    
    func actionButtonTapped() {
        presenter?.showInfoAlert()
    }
}

//MARK: - UITextFieldDelegate
extension CreateEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButtonToKeyboard(textField: textField)
    }
    
    private func addDoneButtonToKeyboard(textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: CreateEventConstants.done, style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        switch textField.tag {
        case 0:
            player = Int(text) ?? 0
            checkCountTFIsNotEmpty(text: text, tf: playersTF)
        case 1:
            let formattedTime = text.formatAsTime()
            timeTF.textField.text = formattedTime
            time = formattedTime.toTimeFormat() ?? ""
            checkTimeTFIsNotEmpty(text: formattedTime, tf: timeTF)
        case 2:
            adress = ""
            addressSuggestionsView.search(query: text)
            checkTFIsNotEmpty(text: text, tf: adressTF)
        case 3:
            place = text
            checkCountTFIsNotEmpty(text: text, tf: placeTF)
        default:
            break
        }
        
        updateValidButton()
    }

    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard player != 0, time.isValidTime, !adress.isEmpty, place != "" else { return false }
        return true
    }
    
}

//MARK: - Setup UI + Configure
extension CreateEventViewController {
    
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(navigationBar)
        view.addSubview(titleDate)
        view.addSubview(subTitle)
        view.addSubview(nextButton)
    }
    
    private func config() {
        navigationBar.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleDateTapped))
        titleDate.isUserInteractionEnabled = true
        titleDate.addGestureRecognizer(tapGesture)

        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        playersTF.textField.delegate = self
        playersTF.textField.tag = 0
        playersTF.textField.keyboardType = .numberPad
        playersTF.textField.returnKeyType = .default
        playersTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        timeTF.textField.delegate = self
        timeTF.textField.tag = 1
        timeTF.textField.keyboardType = .numberPad
        timeTF.textField.returnKeyType = .default
        timeTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        adressTF.textField.delegate = self
        adressTF.textField.tag = 2
        adressTF.textField.returnKeyType = .default
        adressTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        placeTF.textField.delegate = self
        placeTF.textField.tag = 3
        placeTF.textField.returnKeyType = .default
        placeTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        addressSuggestionsView.onAddressSelected = { [weak self] resolved in
            guard let self else { return }
            self.adressTF.textField.text = resolved
            self.adress = resolved
            self.adressTF.textField.resignFirstResponder()
        }
        
        addressSuggestionsView.onInvalidSelection = { [weak self] in
            self?.adress = ""
        }
    }
    
    @objc private func titleDateTapped() {
        let isHidden = !datePicker.isHidden
        
        if !isHidden {
            datePicker.isHidden = false
            datePicker.alpha = 0
            datePicker.date = date
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.datePicker.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                self.datePicker.alpha = 0
            } completion: { _ in
                self.datePicker.isHidden = true
            }
        }
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        date = sender.date
        titleDate.text = "\(CreateEventConstants.eventDate) \(date.toString())"

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.datePicker.alpha = 0
        } completion: { _ in
            self.datePicker.isHidden = true
            self.datePicker.alpha = 1
        }
    }
    
    private func setupConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.Constraint.backButtonSize * 1.2)
        }
        
        titleDate.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        subTitle.snp.makeConstraints { make in
            make.top.equalTo(titleDate.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding + 10)
        }
        
        let playersView = createTFView(text: CreateEventConstants.playersTitle, tf: playersTF)
        let timeView = createTFView(text: CreateEventConstants.startTimeTitle, tf: timeTF)
        let adressView = createTFView(text: CreateEventConstants.addressTitle, tf: adressTF)
        let placeView = createTFView(text: CreateEventConstants.placeTitle, tf: placeTF)
        
        let stack = UIStackView(arrangedSubviews: [playersView, timeView])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.alignment = .fill
        
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(subTitle.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(CreateEventConstants.supViewHeight)
        }
        
        view.addSubview(adressView)
        adressView.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(CreateEventConstants.supViewHeight)
        }
        
        view.addSubview(placeView)
        placeView.snp.makeConstraints { make in
            make.top.equalTo(adressView.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(CreateEventConstants.supViewHeight)
        }
        
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(titleDate.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(CreateEventConstants.datePickerHeight)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        view.addSubview(addressSuggestionsView)
        addressSuggestionsView.snp.makeConstraints { make in
            make.top.equalTo(adressView.snp.bottom).offset(4)
            make.leading.trailing.equalTo(adressView)
            make.height.equalTo(280)
        }
    }
}

fileprivate struct CreateEventConstants {
    static let supViewHeight = Constants.Constraint.buttonHeight * 1.8
    static let datePickerHeight = 450

    static let enterData = "create_event.enter_data".loc
    static let addressPlaceholder = "create_event.address_placeholder".loc
    static let playersPlaceholder = "create_event.players_placeholder".loc
    static let timePlaceholder = "create_event.time_placeholder".loc
    static let placePlaceholder = "create_event.place_placeholder".loc
    static let createButton = "create_event.create".loc
    static let done = "common.done".loc

    static let eventDate = "create_event.event_date".loc
    static let playersTitle = "create_event.players".loc
    static let startTimeTitle = "create_event.start_time".loc
    static let addressTitle = "create_event.address".loc
    static let placeTitle = "create_event.place".loc
}

import MapKit

struct AddressSuggestion {
    let title: String
    let subtitle: String
}

protocol AddressCompleterServiceDelegate: AnyObject {
    func addressCompleterService(_ service: AddressCompleterService, didUpdateResults results: [AddressSuggestion])
    func addressCompleterService(_ service: AddressCompleterService, didFailWithError error: Error)
}

protocol AddressCompleterServiceProtocol: AnyObject {
    var delegate: AddressCompleterServiceDelegate? { get set }
    var expectedCity: String { get set }
    
    func search(query: String)
    func selectAddress(at index: Int, completionHandler: @escaping (String?) -> Void)
}

final class AddressCompleterService: NSObject, AddressCompleterServiceProtocol {
    
    weak var delegate: AddressCompleterServiceDelegate?
    var expectedCity: String
    
    private lazy var completer: MKLocalSearchCompleter = {
        let c = MKLocalSearchCompleter()
        c.delegate = self
        c.resultTypes = .address
        return c
    }()
    
    private var completions: [MKLocalSearchCompletion] = []
    
    init(expectedCity: String = "") {
        self.expectedCity = expectedCity
    }
    
    func search(query: String) {
        let prefix = expectedCity.isEmpty ? "" : "\(expectedCity), "
        completer.queryFragment = prefix + query
    }
    
    func selectAddress(at index: Int, completionHandler: @escaping (String?) -> Void) {
        guard completions.indices.contains(index) else {
            completionHandler(nil)
            return
        }
        
        let completion = completions[index]
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, error in
            guard let self else { return }
            
            guard let placemark = response?.mapItems.first?.placemark,
                  let locality = placemark.locality,
                  locality.caseInsensitiveCompare(self.expectedCity) == .orderedSame else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            let street = placemark.thoroughfare
            let number = placemark.subThoroughfare
            let fullAddress = [street, number].compactMap { $0 }.joined(separator: ", ")
            let result = fullAddress.isEmpty ? placemark.name : fullAddress
            
            DispatchQueue.main.async { completionHandler(result) }
        }
    }
}

extension AddressCompleterService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
        
        let suggestions = completions.map { AddressSuggestion(title: $0.title, subtitle: $0.subtitle) }
        delegate?.addressCompleterService(self, didUpdateResults: suggestions)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completions = []
        delegate?.addressCompleterService(self, didFailWithError: error)
    }
}

import UIKit

final class AddressSuggestionsView: UIView {
    
    var expectedCity: String {
        get { addressService.expectedCity }
        set { addressService.expectedCity = newValue }
    }
    
    var onAddressSelected: ((String) -> Void)?
    var onInvalidSelection: (() -> Void)?
    
    private let addressService: AddressCompleterServiceProtocol
    private var suggestions: [AddressSuggestion] = [] {
        didSet {
            isHidden = suggestions.isEmpty
            tableView.reloadData()
        }
    }
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.separatorInset = .zero
        return tv
    }()
    
    init(addressService: AddressCompleterServiceProtocol = AddressCompleterService()) {
        self.addressService = addressService
        super.init(frame: .zero)
        isHidden = true
        self.addressService.delegate = self
        setupLayout()
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func search(query: String) {
        guard !query.isEmpty else {
            clear()
            return
        }
        addressService.search(query: query)
    }
    
    func clear() {
        suggestions = []
    }
    
    private func setupLayout() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configure() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension AddressSuggestionsView: AddressCompleterServiceDelegate {
    func addressCompleterService(_ service: AddressCompleterService, didUpdateResults results: [AddressSuggestion]) {
        suggestions = results
    }
    
    func addressCompleterService(_ service: AddressCompleterService, didFailWithError error: Error) {
        suggestions = []
    }
}

extension AddressSuggestionsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = suggestions[indexPath.row].title
        cell.detailTextLabel?.text = suggestions[indexPath.row].subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressService.selectAddress(at: indexPath.row) { [weak self] resolved in
            guard let self else { return }
            guard let resolved else {
                self.onInvalidSelection?()
                return
            }
            self.clear()
            self.onAddressSelected?(resolved)
        }
    }
}
