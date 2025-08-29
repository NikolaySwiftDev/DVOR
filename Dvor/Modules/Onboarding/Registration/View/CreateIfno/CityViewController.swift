import UIKit


final class CityViewController: BaseRegistrationViewController {
    
    //MARK: - Properties
    private var city = ""
    var onNext: ((String) -> Void)?
    
    //MARK: - UI
    private let cityCV = BaseCollectionView(collectionType: .city)

    
    //MARK: - View Didload
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configure()
    }

    //MARK: - Next Button Action
    override func nextButtonTapped() {
        onNext?(city)
    }
}

//MARK: - Collection View Delegate
extension CityViewController: BaseCollectionViewProtocol {
    func cellDidTapped(data: String, collectionType: ProfileInfo) {
        city = data
        configureEnadle(checkValidButton())
    }
}

//MARK: - setupLayout + config
extension CityViewController {
    private func setupLayout() {
        view.addSubview(cityCV)
        cityCV.snp.makeConstraints { make in
            make.top.equalTo(descTitleLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.Constraint.cellHeight * 1.2)
        }
    }
    
    private func configure() {
        cityCV.cellDelegate = self
    }
    
    //MARK: - Check Valid Button
    private func checkValidButton() -> Bool {
        guard city != "" else { return false }
        return true
    }
}
