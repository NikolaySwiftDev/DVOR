

import UIKit

final class CreateEventViewController: UIViewController {
    
    var presenter: CreateEventPresenterProtocol?
    private var date: Date
    private var player = 0
    private var time = ""
    private var adress = ""
    private var heightKeyboard: CGFloat = Constants.Constraint.verticalPadding
    
    private let navigationBar = SupportNavigationBar(titleText: "Создание события")
    private let subTitle = UILabel.init(text: "Введите данные")
    private let titleDate = UILabel.init(font: .poppins(weight: .regular, size: .small), textAlignment: .center)
    private let adressTF = AuthTextFieldView(placeholder: "Адрес")
    private let playersTF = AuthTextFieldView(placeholder: "8x8")
    private let timeTF = AuthTextFieldView(placeholder: "Время")
    private let nextButton = UIButton.createStandartButton(title: "Создать", target: self, action: #selector(nextButtonTapped))

    
    init(date: Date) {
        self.date = date
        titleDate.text = "Событие на - \(date.toString())"
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
        presenter?.writeEvent(players: player, date: date, time: time, address: adress)
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
}

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
    
}

//MARK: - Setup UI
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
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        switch textField.tag {
        case 0:
            player = Int(text) ?? 0
            checkTFIsNotEmpty(text: text, tf: playersTF)
        case 1:
            let formattedTime = text.formatAsTime()
            timeTF.textField.text = formattedTime
            time = formattedTime.toTimeFormat() ?? ""
        case 2:
            adress = text
            checkTFIsNotEmpty(text: text, tf: adressTF)
            
        default:
            break
        }
        
        nextButton.backgroundColor = checkValidButton() ? Constants.Colors.buttonActiveColor : Constants.Colors.buttonInActiveColor
        nextButton.isEnabled = checkValidButton()
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard player != 0, time.isValidTime,  adress != "" else { return false }
        return true
    }
    
    private func setupConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.Constraint.backButtonSize * 1.2)
        }
        
        titleDate.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(Constants.Constraint.verticalPadding * 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        subTitle.snp.makeConstraints { make in
            make.top.equalTo(titleDate.snp.bottom).offset(Constants.Constraint.verticalPadding * 2)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding + 10)
        }
        
        let playersView = createTFView(text: "Игроков в команде", tf: playersTF)
        let timeView = createTFView(text: "Время начала игры", tf: timeTF)
        let adressView = createTFView(text: "Адресс", tf: adressTF)
        
        let stack = UIStackView(arrangedSubviews: [playersView, timeView])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.alignment = .fill
        
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(subTitle.snp.bottom).offset(Constants.Constraint.verticalPadding * 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight * 2)
        }
        
        view.addSubview(adressView)
        adressView.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight * 2)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(heightKeyboard)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
}
