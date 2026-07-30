import UIKit

final class DetailViewController: UIViewController {
        
    //MARK: - Properties
    var presenter: DetailPresenterProtocol?
    var detail: DetailModel
    var viewPosition: DetailSegmentViewPosition = .info

    private let mapView = DetailMapView()
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))

    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private let addUserButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(addUserButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private let removeUserButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "person.badge.minus"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(removeUserButtonTapped), for: .touchUpInside)
        return btn
    }()


    private lazy var titleAdress = UILabel(text: detail.address,
                                           font: .poppins(weight: .medium, size: .mid),
                                           textColor: DetailConstants.textColor,
                                           textAlignment: .center)
    
    private let segmentView = DetailSegmentContainerView()
    
    
    //MARK: - Init
    init(details: DetailModel) {
        self.detail = details
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
        presenter?.fetchAllUsers(usersID: detail.users, orgID: detail.orgID)
    }
    
    //MARK: - Back Button Tapped
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }

    //MARK: - Share Button Tapped
    @objc private func shareButtonTapped() {
        presenter?.shareEvent(eventID: detail.id)
    }
    
    //MARK: - Add User Button Tapped
    @objc private func addUserButtonTapped() {
        let city = detail.toCityModel()
        presenter?.addUserToEvent(idEvent: detail.id,
                                  date: detail.date,
                                  time: detail.formattedTime,
                                  isComplete: detail.peopleAllCountInt < 1,
                                  city: city)
    }
    
    //MARK: - Remove User Button Tapped
    @objc private func removeUserButtonTapped() {
        presenter?.removeUserFromEvent(idEvent: detail.id)
    }
 
    deinit {
        // print("Deinit Detail Event")
    }
}

//MARK: - Detail Protocol
extension DetailViewController: DetailProtocol {
    func updateUsers(model: [String]) {
        presenter?.fetchAllUsers(usersID: model, orgID: detail.orgID)
    }
    
    func success(users: [UserModel], org: OrganizatorModel) {
        hideLoadingView(with: view, tag: DetailConstants.numberView, state: .delete)
        segmentView.configureAllViews(detail: detail, users: users, org: org)
    }
    
    func load() {
        hideLoadingView(with: view, tag: DetailConstants.numberView, state: .add)
    }
    
    func error(error: String) {
        hideLoadingView(with: view, tag: DetailConstants.numberView, state: .delete)
    }
    
    func hideLoading() {
        hideLoadingView(with: view, tag: DetailConstants.numberView, state: .delete)
    }
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
extension DetailViewController: DetailViewDelegate {
    func mapButtonTapped() {
        presenter?.showLocationOnMap(location: detail.fullAdress)
    }
}

//MARK: - Extension SetupView, Configure and SetupContraints
private extension DetailViewController {
    private func setupView() {

        view.backgroundColor = Constants.Colors.backgroungColor
        
        view.addSubview(backButton)
        view.addSubview(shareButton)
        view.addSubview(addUserButton)
        view.addSubview(removeUserButton)
        view.addSubview(titleAdress)
        view.addSubview(mapView)
        view.addSubview(segmentView)
    }
    
    private func configure() {
        segmentView.usersView.delegate = self
        mapView.delegate = self
        mapView.configure(with: detail.fullAdress)
    }
    
    private func setupContraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(DetailConstants.paddingStandart)
        }
        
        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().inset(DetailConstants.paddingStandart)
            make.height.width.equalTo(DetailConstants.heightBackBtn)
        }
        
        addUserButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalTo(removeUserButton.snp.leading).offset(-10)
            make.height.width.equalTo(DetailConstants.heightBackBtn)
        }
        
        removeUserButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalTo(shareButton.snp.leading).offset(-10)
            make.height.width.equalTo(DetailConstants.heightBackBtn)
        }
        
        titleAdress.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(DetailConstants.paddingHorizontal)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(titleAdress.snp.bottom).offset(DetailConstants.paddingStandart)
            make.leading.equalToSuperview().offset(DetailConstants.paddingHorizontal)
            make.trailing.equalToSuperview().inset(DetailConstants.paddingHorizontal)
            make.height.equalTo(DetailConstants.heightMapImg)
        }
        
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(DetailConstants.paddingStandart)
            make.leading.equalToSuperview().offset(DetailConstants.paddingHorizontal)
            make.trailing.equalToSuperview().inset(DetailConstants.paddingHorizontal)
            make.bottom.equalToSuperview().inset(DetailConstants.paddingStandart)
        }
    }
}

fileprivate struct DetailConstants {
    static let textColor: UIColor = .black
    static let paddingStandart: CGFloat = 20
    static let paddingHorizontal: CGFloat = 20
    static let cornerRadius: CGFloat = 10
    static let heightBackBtn: CGFloat = 25
    static let heightMapImg: CGFloat = UIScreen.main.bounds.height / 4.7
    static let numberView: Int = 33
    
}
 

