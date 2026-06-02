

import UIKit

final class CreateEventViewController: UIViewController {
    
    var presenter: CreateEventPresenterProtocol?
    private var date: Date
    private var player = 0
    private var time = ""
    private var adress = ""
    private var place = ""
    
    private let navigationBar = SupportNavigationBar(state: .createEvent)
    private let subTitle = UILabel.init(text: "Введите данные")
    private let titleDate = UILabel.init(font: .poppins(weight: .regular, size: .small), textAlignment: .center)
    private let adressTF = AuthTextFieldView(placeholder: "ул. Любых, д.20, к1")
    private let playersTF = AuthTextFieldView(placeholder: "8")
    private let timeTF = AuthTextFieldView(placeholder: "11:22")
    private let placeTF = AuthTextFieldView(placeholder: "школа № 29")
    private let nextButton = UIButton.createStandartButton(title: "Создать", target: self, action: #selector(nextButtonTapped))
    
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
        titleDate.text = "Событие на \(date.toString())"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        config()
    }
    
    @objc private func nextButtonTapped() {
        presenter?.writeEvent(players: player, date: date, time: time, address: adress, place: place)
    }
    
    deinit {
        print("deinit CreateEventViewController")
    }
}

//MARK: - Create Event Protocol
extension CreateEventViewController: CreateEventProtocol {
    func success() {}
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
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneButtonTapped))
        
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
            adress = text
            checkTFIsNotEmpty(text: text, tf: adressTF)
            
        case 3:
            place = text
            checkTFIsNotEmpty(text: text, tf: placeTF)
            
        default:
            break
        }
        
        nextButton.backgroundColor = checkValidButton() ? Constants.Colors.buttonActiveColor : Constants.Colors.buttonInActiveColor
        nextButton.isEnabled = checkValidButton()
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard player != 0, time.isValidTime, adress != "", place != "" else { return false }
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
        playersTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        timeTF.textField.delegate = self
        timeTF.textField.tag = 1
        timeTF.textField.keyboardType = .numberPad
        timeTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        adressTF.textField.delegate = self
        adressTF.textField.tag = 2
        adressTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        placeTF.textField.delegate = self
        placeTF.textField.tag = 3
        placeTF.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        titleDate.text = "Событие на \(sender.date.toString())"
        
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
        
        let playersView = createTFView(text: "Игроков в команде", tf: playersTF)
        let timeView = createTFView(text: "Время начала игры", tf: timeTF)
        let adressView = createTFView(text: "Адресс", tf: adressTF)
        let placeView = createTFView(text: "Место", tf: placeTF)
        
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
    }
}

fileprivate struct CreateEventConstants {
    static let supViewHeight = Constants.Constraint.buttonHeight * 1.8
    static let datePickerHeight = 450
}
