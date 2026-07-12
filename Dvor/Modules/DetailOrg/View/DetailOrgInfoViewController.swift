import UIKit
import SnapKit

final class DetailOrgInfoViewController: UIViewController {

    var presenter: DetailOrgInfoPresenterProtocol?
    
    // MARK: - Model
    let model: OrganizatorModel
    
    // MARK: - UI Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    private let orgImageView = UIImageView(cornerRadius: DetailOrgInfoConstants.cornerRadius)
    
    private let titleLabel = UILabel(text: DetailOrgInfoConstants.organizerTitle.loc, font: .poppins(weight: .bold, size: .big), textColor: .white)
    private let nameLabel = UILabel(text: "", textColor: .white)
    private let aboutTitle = UILabel(text: DetailOrgInfoConstants.aboutTitle.loc, font: .poppins(weight: .bold, size: .big), textColor: .white)
    private let aboutText = UILabel(text: "", textColor: Constants.Colors.inActiveColor)
    private let responsibilitiesTitle = UILabel(text: DetailOrgInfoConstants.responsibilitiesTitle.loc, font: .poppins(weight: .bold, size: .big), textColor: .white)
    private let responsibilitiesStack = UIStackView()
    private let reminderLabel = UILabel(text: DetailOrgInfoConstants.reminderText.loc,
                                        textColor: Constants.Colors.inActiveColor)
    
    // MARK: - Init
    init(model: OrganizatorModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithModel()
        setupConstraints()
    }
    
    //MARK: - Back Button Tapped
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        mainStackView.alignment = .leading
        
        responsibilitiesStack.axis = .vertical
        responsibilitiesStack.spacing = 8
        responsibilitiesStack.alignment = .leading
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
//        contentView.addSubview(backButton)
        
        mainStackView.addArrangedSubview(orgImageView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(aboutTitle)
        mainStackView.addArrangedSubview(aboutText)
        mainStackView.addArrangedSubview(responsibilitiesTitle)
        mainStackView.addArrangedSubview(responsibilitiesStack)
        mainStackView.addArrangedSubview(reminderLabel)
        
        Responsibilities.responsibilities.forEach { text in
            let label = UILabel(text: text, font: .poppins(weight: .medium, size: .mid), textColor: .white)
            responsibilitiesStack.addArrangedSubview(label)
        }
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DetailOrgInfoConstants.paddingStandart)
            make.leading.trailing.equalToSuperview().inset(DetailOrgInfoConstants.paddingStandart)
            make.bottom.equalToSuperview().offset(-DetailOrgInfoConstants.paddingStandart)
        }
        
        orgImageView.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height).multipliedBy(0.4)
            make.width.equalToSuperview()
        }
    }
    
    // MARK: - Cconfigure
    private func configureWithModel() {
        nameLabel.text = model.name
        aboutText.text = DetailOrgInfoConstants.contactInChat.loc
        
        if let imageData = model.image, let image = UIImage(data: imageData) {
            orgImageView.image = image
        } else {
            orgImageView.image = UIImage(systemName: "person.and.background.dotted")
            orgImageView.tintColor = Constants.Colors.layerColor
        }
    }
    
    deinit {
        print("deinit DetailOrgInfoViewController")
    }
}

//MARK: - Detail Org Info Protocol
extension DetailOrgInfoViewController: DetailOrgInfoProtocol {}

fileprivate struct DetailOrgInfoConstants {
    static let cornerRadius: CGFloat = 10
    static let paddingStandart: CGFloat = 20
    static let heightBackBtn: CGFloat = 40

}

extension DetailOrgInfoConstants {
    static let organizerTitle = "organizer_title".loc
    static let aboutTitle = "about_title".loc
    static let responsibilitiesTitle = "responsibilities_title".loc
    static let reminderText = "reminder_text".loc
    static let contactInChat = "contact_in_chat".loc
}
