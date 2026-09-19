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

    // MARK: - Loading State (Skeleton)
    private let skeletonContainer = UIView()
    
    private let skeletonAvatar = ShimmerPlaceholderView(isAvatar: true)
    private let skeletonName = ShimmerPlaceholderView()
    private let skeletonPosition = ShimmerPlaceholderView()
    private let skeletonStat = ShimmerPlaceholderView()
    private let skeletonSeparator1 = ShimmerPlaceholderView()
    private let skeletonInfoTitle = ShimmerPlaceholderView()
    private let skeletonCityRow = ShimmerPlaceholderView()
    private let skeletonExperienceRow = ShimmerPlaceholderView()
    private let skeletonSeparator2 = ShimmerPlaceholderView()
    
    private lazy var shimmerViews: [ShimmerPlaceholderView] = [
        skeletonAvatar, skeletonName, skeletonPosition, skeletonStat,
        skeletonSeparator1, skeletonInfoTitle, skeletonCityRow,
        skeletonExperienceRow, skeletonSeparator2
    ]
    
    private var isConfigured = false
        
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupSkeletonConstraints()
        startLoading()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Loading
    func startLoading() {
        isConfigured = false
        scrollView.alpha = 0
        scrollView.isHidden = true
        skeletonContainer.isHidden = false
        skeletonContainer.alpha = 1
        shimmerViews.forEach { $0.startShimmer() }
        startBackgroundPulse()
    }
    
    private func stopLoading() {
        guard !isConfigured else { return }
        isConfigured = true
        stopBackgroundPulse()
        
        scrollView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.alpha = 1
            self.skeletonContainer.alpha = 0
        }, completion: { _ in
            self.skeletonContainer.isHidden = true
            self.shimmerViews.forEach { $0.stopShimmer() }
        })
    }
    
    private func startBackgroundPulse() {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = UserCardViewConstan.cardColor.cgColor
        animation.toValue = UserCardViewConstan.cardColor.adjusted(brightnessBy: 0.06).cgColor
        animation.duration = 1.1
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "bgPulse")
    }
    
    private func stopBackgroundPulse() {
        let fadeBack = CABasicAnimation(keyPath: "backgroundColor")
        fadeBack.toValue = UserCardViewConstan.cardColor.cgColor
        fadeBack.duration = 0.3
        fadeBack.fillMode = .forwards
        fadeBack.isRemovedOnCompletion = false
        layer.removeAnimation(forKey: "bgPulse")
        layer.add(fadeBack, forKey: "bgPulseFadeOut")
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
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.stopLoading()
//        }
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
        addSubview(skeletonContainer)
        
        [avatarImageView, fullNameLabel, positionLabel, statsStackView, separatorView1, infoTitleLabel, cityInfoView, experienceInfoView, separatorView2].forEach {
            contentView.addSubview($0)
        }
        
        shimmerViews.forEach { skeletonContainer.addSubview($0) }
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
    
    private func setupSkeletonConstraints() {
        skeletonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        skeletonAvatar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UserCardViewConstan.topPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(UserCardViewConstan.avatarHeight)
            make.width.equalTo(UserCardViewConstan.avatarHeight / 1.2)
        }
        
        skeletonName.snp.makeConstraints { make in
            make.top.equalTo(skeletonAvatar.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(20)
        }
        
        skeletonPosition.snp.makeConstraints { make in
            make.top.equalTo(skeletonName.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(14)
        }
        
        skeletonStat.snp.makeConstraints { make in
            make.top.equalTo(skeletonPosition.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(34)
        }
        
        skeletonSeparator1.snp.makeConstraints { make in
            make.top.equalTo(skeletonStat.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.height.equalTo(1)
        }
        
        skeletonInfoTitle.snp.makeConstraints { make in
            make.top.equalTo(skeletonSeparator1.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(UserCardViewConstan.padding)
            make.width.equalTo(140)
            make.height.equalTo(16)
        }
        
        skeletonCityRow.snp.makeConstraints { make in
            make.top.equalTo(skeletonInfoTitle.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.height.equalTo(18)
        }
        
        skeletonExperienceRow.snp.makeConstraints { make in
            make.top.equalTo(skeletonCityRow.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.height.equalTo(18)
        }
        
        skeletonSeparator2.snp.makeConstraints { make in
            make.top.equalTo(skeletonExperienceRow.snp.bottom).offset(20)
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
//        let lvlView = createStatView(title: UserCardViewConstan.level, value: String(format: "%.0f", stats.level))
//        statsStackView.addArrangedSubview(lvlView)
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

// MARK: - Shimmer Placeholder View
final class ShimmerPlaceholderView: UIView {
    private let gradientLayer = CAGradientLayer()
    var isAvatar = false
    
    init(frame: CGRect = .zero, isAvatar: Bool = false) {
        self.isAvatar = isAvatar
        super.init(frame: frame)
        backgroundColor = UserCardViewConstan.secondTextColor.withAlphaComponent(0.25)
        clipsToBounds = true
        
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = isAvatar ? 25 : bounds.height / 2
        gradientLayer.frame = bounds.insetBy(dx: -bounds.width, dy: 0)
    }
    
    func startShimmer() {
        guard gradientLayer.animation(forKey: "shimmer") == nil else { return }
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.3
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    func stopShimmer() {
        gradientLayer.removeAnimation(forKey: "shimmer")
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
