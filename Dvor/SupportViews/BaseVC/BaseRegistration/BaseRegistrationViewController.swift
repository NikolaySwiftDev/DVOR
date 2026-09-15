import UIKit
import SnapKit

class BaseRegistrationViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: RegistPresenterProtocol?
    
    // MARK: - UI
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    let nextButton = UIButton.createStandartButton(title: "Continue".loc, target: self, action: #selector(nextButtonTapped))
    private let progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = Constants.Colors.layerColor
        progress.tintColor = Constants.Colors.buttonInActiveColor
        progress.isHidden = true
        return progress
    }()
    
    private let pageLabel = UILabel(font: .poppins(weight: .regular, size: .small))
    private let profileTitleLabel = UILabel(font: .poppins(weight: .bold, size: .big))
    let descTitleLabel = UILabel(font: .poppins(weight: .regular, size: .small))

    //MARK: - Init
    init(presenter: RegistPresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, self)
        removeKeyboardObservers()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    // MARK: -  Hide back button
    func setInfoForNavigationView(model: BaseRegistPosition) {
        progressBar.setProgress(model.progress, animated: true)
        progressBar.isHidden = false
        
        pageLabel.text = model.page
        profileTitleLabel.text = model.titleMain
        descTitleLabel.text = model.titleDesc
    }
    
    // MARK: -  Hide back button
    func hideBackButton(_ hide: Bool) {
        backButton.isHidden = hide
    }
    
    // MARK: - Configure Enadle Next Button
    func configureEnadle(_ isEnable: Bool) {
        setNextButtonState(nextButton, isEnabled: isEnable)
    }
    
    func changeNextButtonView(title: String, titleColor: UIColor, backColor: UIColor = Constants.Colors.buttonActiveColor) {
        nextButton.setTitle(title, for: .normal)
        nextButton.backgroundColor = backColor
        nextButton.setTitleColor(titleColor, for: .normal)
        nextButton.isEnabled = true
    }
    
    func hidePageControllView() {
        progressBar.isHidden = true
        pageLabel.isHidden = true
    }
    
    func updateButtonTitle(_ title: String) {
        nextButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Back Button Action
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    // MARK: - Next Button Action
    @objc open func nextButtonTapped() {
        print(#function)
    }
}

private extension BaseRegistrationViewController {
    
    // MARK: - Setup view
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(nextButton)
        view.addSubview(backButton)
        view.addSubview(progressBar)
        view.addSubview(pageLabel)
        view.addSubview(profileTitleLabel)
        view.addSubview(descTitleLabel)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
        }
        
        pageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        progressBar.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.leading.equalTo(backButton.snp.trailing).offset(Constants.Constraint.horizPadding * 2)
            make.trailing.equalTo(pageLabel.snp.leading).offset(-Constants.Constraint.horizPadding * 2)
            make.height.equalTo(BaseConstants.progressHeight)
        }
        
        profileTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        descTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            let constraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.Constraint.verticalPadding).constraint
            observeKeyboard(for: constraint)
            $0.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
}
