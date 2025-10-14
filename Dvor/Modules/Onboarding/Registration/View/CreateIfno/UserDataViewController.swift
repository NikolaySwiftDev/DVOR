import UIKit


final class UserDataViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    private var position = ""
    private var experience = ""
    var onNext: ((String, String) -> Void)?
    
    //MARK: - UI
    private let positionCV = BaseRegistrationCollectionView(collectionType: .position)
    private let experienceCV = BaseRegistrationCollectionView(collectionType: .experience)
    
    private let positionLabel = UILabel(text: ProfileInfo.position.title, font: .poppins(weight: .medium, size: .small))
    private let experienceLabel = UILabel(text: ProfileInfo.experience.title, font: .poppins(weight: .medium, size: .small))
    
    //MARK: - View Didload
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configure()
    }

    //MARK: - Next Button Action
    override func nextButtonTapped() {
        onNext?(position, experience)
        print("Дата", position, experience)
    }
}

//MARK: - Collection View Delegate
extension UserDataViewController: BaseCollectionViewProtocol {
    func cellDidTapped(data: String, collectionType: ProfileInfo) {
        switch collectionType {
        case .position:
            position = data
        case .experience:
            experience = data
        case .city:
            break
        }
        configureEnadle(checkValidButton())
    }
}

//MARK: - setupLayout + config
private extension UserDataViewController {
    private func setupLayout() {
        view.addSubview(positionCV)
        view.addSubview(experienceCV)
        view.addSubview(positionLabel)
        view.addSubview(experienceLabel)
        
        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(descTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding * 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        positionCV.snp.makeConstraints { make in
            make.top.equalTo(positionLabel.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.Constraint.cellHeight * 1.2)
        }
        
        experienceLabel.snp.makeConstraints { make in
            make.top.equalTo(positionCV.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        experienceCV.snp.makeConstraints { make in
            make.top.equalTo(experienceLabel.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.Constraint.cellHeight * 1.2)
        }
    }
    
    private func configure() {
        positionCV.cellDelegate = self
        experienceCV.cellDelegate = self
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard position != "", experience != "" else { return false }
        return true
    }
}
