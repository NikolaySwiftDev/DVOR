//import UIKit
//import SnapKit
//
//protocol UserProfileViewDelegate: AnyObject {
//    func followButtonDidTap()
//}
//
//final class UserProfileView: UIView {
//    
//    weak var delegate: UserProfileViewDelegate?
//        
//    // MARK: - UI Elements
//    private let mainStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .vertical
//        stack.spacing = 4
//        stack.alignment = .center
//        return stack
//    }()
//    
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.font = .boldSystemFont(ofSize: 20)
//        label.textColor = .white
//        return label
//    }()
//    
//    private let infoLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .white
//        return label
//    }()
//    
//    private let statsLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .white
//        return label
//    }()
//    
//    private let clubLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .white
//        return label
//    }()
//
//    private let followButton = UIButton.createStandartButton(title: "Follow", target: self, action: #selector(followButtonTapped))
//    
//    // MARK: - Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//        setupConstraints()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    @objc private func followButtonTapped() {
//        delegate?.followButtonDidTap()
//    }
//    
//    // MARK: - Configuration
//    func configure(with model: UserModel) {
//        nameLabel.text = model.name
//        infoLabel.text = "\(model.gender) • \(model.age) \("age".loc))"
//        statsLabel.text = "\(model.followers) subscribers • \(model.following) subscriptions"
//        clubLabel.text = model.club
//    }
//    
//    // MARK: - Private Methods
//    private func setupView() {
//        backgroundColor = .darkGreen
//        layer.cornerRadius = 12
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.1
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowRadius = 4
//
//        mainStackView.addArrangedSubview(nameLabel)
//        mainStackView.addArrangedSubview(infoLabel)
//        mainStackView.addArrangedSubview(statsLabel)
//        mainStackView.addArrangedSubview(clubLabel)
//        mainStackView.addArrangedSubview(followButton)
//        
//        addSubview(mainStackView)
//    }
//    
//    private func setupConstraints() {
//        mainStackView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(5)
//            make.leading.trailing.equalToSuperview().inset(16)
//            make.bottom.equalToSuperview().offset(-20)
//        }
//        
//        followButton.snp.makeConstraints { make in
//            make.width.equalToSuperview().multipliedBy(0.6)
//            make.height.equalTo(44)
//        }
//    }
//}
