import UIKit
import SnapKit

final class UserCardView: UIView {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Avatar Section
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = UserCardViewConstan.secondTextColor
        return imageView
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.poppins(weight: .bold, size: .big)
        label.textColor = UserCardViewConstan.textColor
        label.textAlignment = .center
        return label
    }()
    
    private let positionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.poppins(weight: .semiBold, size: .mid)
        label.textColor = UserCardViewConstan.secondTextColor
        label.textAlignment = .center
        return label
    }()
    
    // Stats Section
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private let separatorView1: UIView = {
        let view = UIView()
        view.backgroundColor = UserCardViewConstan.secondTextColor
        return view
    }()
    
    // Info Section
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = UserCardViewConstan.title
        label.font = UIFont.poppins(weight: .semiBold, size: .mid)
        label.textColor = UserCardViewConstan.textColor
        return label
    }()
    
    private let cityInfoView = InfoRowView(icon: "location.fill", title: UserCardViewConstan.city)
    private let experienceInfoView = InfoRowView(icon: "sportscourt.fill", title: UserCardViewConstan.experience)

    
    private let separatorView2: UIView = {
        let view = UIView()
        view.backgroundColor = UserCardViewConstan.secondTextColor
        return view
    }()
        
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with model: UserModel) {
        // Avatar and name
        if let imageData = model.image, let image = UIImage(data: imageData) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .gray
        }
        
        fullNameLabel.text = model.fullName
        positionLabel.text = model.position
        
        // Stats
        setupStats(with: model)
        
        // Personal info
        cityInfoView.setValue(model.city)
        experienceInfoView.setValue(model.experience)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundColor = UserCardViewConstan.cardColor
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [avatarImageView, fullNameLabel, positionLabel, statsStackView, separatorView1, infoTitleLabel, cityInfoView, experienceInfoView, separatorView2].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UserCardViewConstan.topPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(UserCardViewConstan.avatarHeight)
            make.width.equalTo(UserCardViewConstan.avatarHeight / 1.2)
        }
        
        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
        }
        
        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(positionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.height.equalTo(60)
        }
        
        separatorView1.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.height.equalTo(1)
        }
        
        infoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView1.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
        }
                
        cityInfoView.snp.makeConstraints { make in
            make.top.equalTo(infoTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
        }

        experienceInfoView.snp.makeConstraints { make in
            make.top.equalTo(cityInfoView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
        }
        
        separatorView2.snp.makeConstraints { make in
            make.top.equalTo(experienceInfoView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.height.equalTo(1)
        }
    }
    
    private func setupStats(with stats: UserModel) {
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Plays
        let playsView = createStatView(title: UserCardViewConstan.games, value: "\(stats.plays)")
        statsStackView.addArrangedSubview(playsView)
        
        // LVL
        let lvlView = createStatView(title: UserCardViewConstan.level, value: String(format: "%.0f", stats.level))
        statsStackView.addArrangedSubview(lvlView)
    }
    
    private func createStatView(title: String, value: String) -> UIView {
        let container = UIView()
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.poppins(weight: .semiBold, size: .mid)
        valueLabel.textColor = UserCardViewConstan.textColor
        valueLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.poppins(weight: .regular, size: .mid)
        titleLabel.textColor = UserCardViewConstan.secondTextColor
        titleLabel.textAlignment = .center
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return container
    }
}

// MARK: - Info Row View
final class InfoRowView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UserCardViewConstan.secondTextColor
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.poppins(weight: .regular, size: .mid)
        label.textColor = Constants.Colors.inActiveColor
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.poppins(weight: .regular, size: .mid)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    init(icon: String, title: String) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
    
    private func setupView() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(UserCardViewConstan.padding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.trailing.centerY.equalToSuperview()
        }
    }
}

fileprivate struct UserCardViewConstan {
    static let cardColor: UIColor = Constants.Colors.layerColor
    static let textColor: UIColor = .white
    static let secondTextColor: UIColor = Constants.Colors.inActiveColor
    static let padding: CGFloat = 20
    static let topPadding: CGFloat = 20
    static let avatarHeight: CGFloat = 250
    
    static let title = "info.personal_information".loc
    static let experience = "info.experience".loc
    static let games = "info.games".loc
    static let level = "info.level".loc
    static let city = "info.city".loc
}
