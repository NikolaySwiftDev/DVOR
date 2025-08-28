import UIKit
import SnapKit



class BaseRegistrationViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: RegistPresenterProtocol?
    private var heightKeyboard: CGFloat = Constants.Constraint.verticalPadding
    
    // MARK: - UI
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    let nextButton = UIButton.createStandartButton(title: "Продолжить", target: self, action: #selector(nextButtonTapped))
    private let progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = Constants.Colors.layerColor
        progress.tintColor = Constants.Colors.buttonInActiveColor
        progress.isHidden = true
        return progress
    }()
    
    private let pageLabel = UILabel(font: .poppins(weight: .regular, size: .small))
    private let profileTitleLabel = UILabel(font: .poppins(weight: .bold, size: .big))
    
    let descTitleLabel: UILabel = {
        let label = UILabel(font: .poppins(weight: .regular, size: .small))
        return label
    }()
    
    
    //MARK: - Init
    init(presenter: RegistPresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
//        configureEnadle(false)
    }
    
    // MARK: -  Hide back button
    func setInfoForNavigationView(model: BaseRegistPosition) {
        progressBar.setProgress(model.progress, animated: true)
        progressBar.isHidden = model.showTitleView
        
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
        nextButton.backgroundColor = isEnable ? Constants.Colors.buttonActiveColor : Constants.Colors.buttonInActiveColor
        nextButton.isEnabled = isEnable
    }
    
    
    func changeNextButtonView(title: String, titleColor: UIColor, backColor: UIColor = Constants.Colors.buttonActiveColor) {
        nextButton.setTitle(title, for: .normal)
        nextButton.backgroundColor = backColor
        nextButton.setTitleColor(titleColor, for: .normal)
        nextButton.isEnabled = true
    }
    
    // MARK: - Configure Bottom Padding Next Buttom
    func configureBottomPaddingButtom(isActiveTF: Bool, isNumberPad: Bool = true) {
        let newInset =  isActiveTF ?
                        isNumberPad ? BaseConstants.bottomPaddingNumberPad
                                    : BaseConstants.bottomPaddingKeyboard : Constants.Constraint.horizPadding
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
            self.nextButton.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(newInset)
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
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
            make.size.equalTo(BaseConstants.backButtonSize)
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
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(heightKeyboard)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }
}


// MARK: - Auth Constants
fileprivate struct BaseConstants {
    static let bottomPaddingNumberPad: CGFloat = (UIScreen.main.bounds.height / 3.1)
    static let bottomPaddingKeyboard: CGFloat = (UIScreen.main.bounds.height / 2.7)
    static let progressHeight: CGFloat = 4
    static let backButtonSize: CGFloat = 24

}
