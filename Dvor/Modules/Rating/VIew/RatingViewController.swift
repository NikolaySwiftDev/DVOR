import UIKit
import SnapKit

final class RatingViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: RatingPresenterProtocol?
    let model: UserModel
    private var selectedRating: Int? {
        didSet {
            saveButton.isEnabled = true
            updateRatingButtons()
        }
    }
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = RatingVCConstant.title
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    private let importantLabel: UILabel = {
        let label = UILabel()
        label.text = RatingVCConstant.important
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = RatingVCConstant.description
        label.font = .systemFont(ofSize: 14)
        label.textColor = Constants.Colors.inActiveColor
        label.numberOfLines = 0
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.inActiveColor
        return view
    }()
    
    private let userView = UserRatingView()
    
    private let attitudeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = RatingVCConstant.attitudeTitle
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let attitudeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = RatingVCConstant.attitudeDescription
        label.font = .systemFont(ofSize: 14)
        label.textColor = Constants.Colors.inActiveColor
        label.numberOfLines = 0
        return label
    }()
    
    private let ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private let saveButton = UIButton.createStandartButton(title: RatingVCConstant.saveButton)
    
    // MARK: - Init
    init(model: UserModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        configureUI()
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    @objc private func saveButtonTapped() {
        guard let rate = selectedRating else {return}
        presenter?.saveRating(rate: rate)
    }
    
    // MARK: - update Rating Buttons UI
    private func updateRatingButtons() {
        ratingStackView.arrangedSubviews.forEach { view in
            guard let button = view as? RatingButton else { return }
            let isSelected = button.ratingValue == selectedRating
            button.backgroundColor = isSelected ? .systemGreen : .darkGray
            button.layer.borderColor = isSelected ? UIColor.systemGreen.cgColor : Constants.Colors.inActiveColor.cgColor
        }
    }
    
    deinit {
        // print("deinit RatingViewController")
    }
}

// MARK: - Setup
extension RatingViewController {
    private func setupView() {
        view.backgroundColor = RatingVCConstant.backColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [backButton, titleLabel, importantLabel, descriptionLabel,
         separatorView, userView, attitudeTitleLabel,
         attitudeDescriptionLabel, ratingStackView, saveButton].forEach {
            contentView.addSubview($0)
        }

    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(20)
//            make.size.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        importantLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(importantLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        userView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        attitudeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(userView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        attitudeDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(attitudeTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(attitudeDescriptionLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(ratingStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func configureUI() {
        userView.configure(with: model)

        RatingModel.init().ratingOptions.forEach { title, value in
            let button = RatingButton(title: title, ratingValue: value)
            button.didSelectRating = { [weak self] rating in
                self?.selectedRating = rating
            }
            ratingStackView.addArrangedSubview(button)
        }
        
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Rating Protocol
extension RatingViewController: RatingProtocol {}

// MARK: - Rating Button
final class RatingButton: UIButton {
    let ratingValue: Int
    
    init(title: String, ratingValue: Int) {
        self.ratingValue = ratingValue
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14)
        backgroundColor = .darkGray
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = Constants.Colors.inActiveColor.cgColor
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTap() {
        didSelectRating?(ratingValue)
    }
    
    var didSelectRating: ((Int) -> Void)?
}

// MARK: - User Rating View
final class UserRatingView: UIView {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let positionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = Constants.Colors.inActiveColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: UserModel) {
        nameLabel.text = model.name
        positionLabel.text = model.position
    }
    
    private func setupView() {
        addSubview(nameLabel)
        addSubview(positionLabel)
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

fileprivate struct RatingVCConstant {
    static let backColor: UIColor = .backgrDarkGreen

    static let title = "rating.title".loc
    static let important = "rating.important".loc
    static let description = "rating.description".loc

    static let attitudeTitle = "rating.attitude.title".loc
    static let attitudeDescription = "rating.attitude.description".loc

    static let saveButton = "common.save".loc
}
