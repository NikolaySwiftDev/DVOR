import UIKit

final class DetailViewController: UIViewController {
        
    //MARK: - Properties
    var presenter: DetailPresenterProtocol?
    var details: DetailModel
    var viewPosition: DetailSegmentViewPosition = .users

    private let mapImage: UIImageView = {
        let image = UIImageView.init(image: UIImage(systemName: "photo.artframe"))
        image.backgroundColor = .white
        image.layer.cornerRadius = DetailConstants.cornerRadius
        return image
    }()
    
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))


    private let shareButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "link.circle.fill")
        config.baseForegroundColor = .mediumGreen
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)

        let btn = UIButton(configuration: config, primaryAction: nil)
        btn.layer.cornerRadius = DetailConstants.heightBackBtn / 2
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return btn
    }()


    private lazy var titleAdress = UILabel(text: details.address,
                                           font: .poppins(weight: .medium, size: .mid),
                                           textColor: DetailConstants.textColor,
                                           textAlignment: .center)
    
    private let segmentView = DetailSegmentContainerView()
    
    
    //MARK: - Init
    init(details: DetailModel) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configure()
        setupContraints()
        presenter?.fetchAllUsers(usersID: details.users)
    }
    
    //MARK: - Back Button Tapped
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }

    //MARK: - Share Button Tapped
    @objc private func shareButtonTapped() {
        print(#function)
    }
 
    deinit {
        print("Deinit Detail Event")
    }
}

//MARK: - Detail Protocol
extension DetailViewController: DetailProtocol {
    func getModel() {}
}

//MARK: - Detail User Protocol
extension DetailViewController: UserCellProtocol {
    func orgCellTapped(_ model: OrganizatorModel) {
    //Org cell delegate
        presenter?.showDetailOrgInfo(model: model)
    }
    
    //User cell delegate
    func userCellTapped(_ model: UserModel) {
        presenter?.showBottomAlertForUser(model: model)
    }
}

//MARK: - Detail Info Protocol
extension DetailViewController: InfoViewProtocol {
    func mapButtonTapped() {
        presenter?.showLocationOnMap(location: details.address)
    }
}

//MARK: - Extension SetupView, Configure and SetupContraints
private extension DetailViewController {
    private func setupView() {

        view.backgroundColor = Constants.Colors.backgroungColor
        
        view.addSubview(backButton)
        view.addSubview(shareButton)
        view.addSubview(titleAdress)
        view.addSubview(mapImage)
        view.addSubview(segmentView)
    }
    
    private func configure() {
        segmentView.configureAllViews(details)

        segmentView.usersView.delegate = self
        segmentView.infoView.delegate = self
        
    }
    
    private func setupContraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(DetailConstants.paddingStandart)
            make.height.width.equalTo(DetailConstants.heightBackBtn)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalToSuperview().inset(DetailConstants.paddingStandart)
            make.height.width.equalTo(DetailConstants.heightBackBtn)
        }
        
        titleAdress.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(DetailConstants.paddingHorizontal)
            make.trailing.equalTo(shareButton.snp.leading).inset(-DetailConstants.paddingHorizontal)
        }
        
        mapImage.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(DetailConstants.paddingStandart)
            make.leading.equalToSuperview().offset(DetailConstants.paddingHorizontal)
            make.trailing.equalToSuperview().inset(DetailConstants.paddingHorizontal)
            make.height.equalTo(DetailConstants.heightMapImg)
        }
        
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(mapImage.snp.bottom).offset(DetailConstants.paddingStandart)
            make.leading.equalToSuperview().offset(DetailConstants.paddingHorizontal)
            make.trailing.equalToSuperview().inset(DetailConstants.paddingHorizontal)
            make.bottom.equalToSuperview().inset(DetailConstants.heightTabbar)
        }
    }
}

fileprivate struct DetailConstants {
    static let backColor: UIColor = .backgrDarkGreen
    static let textColor: UIColor = .textDesc
    static let paddingStandart: CGFloat = 20
    static let paddingHorizontal: CGFloat = 20
    static let cornerRadius: CGFloat = 10
    static let heightBackBtn: CGFloat = 40
    static let heightTabbar: CGFloat = 90
    static let heightMapImg: CGFloat = UIScreen.main.bounds.height / 4.7
}
 

