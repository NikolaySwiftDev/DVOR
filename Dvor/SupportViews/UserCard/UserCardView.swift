import UIKit
import SnapKit

final class UserCardView: UIView {
    
    // MARK: - UI Elements
    private let avatarImageView = UIImageView(cornerRadius: 40)
    private let usernameLabel = UILabel(textColor: .yellow)
    private let eventsPlayedLabel = UILabel(textColor: .yellow)
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 4
        return stack
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
        if let imageData = model.image, let image = UIImage(data: imageData) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.and.background.dotted")
        }
        usernameLabel.text = model.name
        
        setupStats(with: model)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundColor = UserCardViewConstan.cardColor
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(avatarImageView)
        addSubview(usernameLabel)
        addSubview(eventsPlayedLabel)
        addSubview(statsStackView)
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UserCardViewConstan.topPadding)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.height.equalTo(UserCardViewConstan.heightImage)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(UserCardViewConstan.topPadding)
            make.centerX.equalToSuperview()
        }
        
        eventsPlayedLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(4)
            make.leading.equalTo(usernameLabel)
            make.trailing.equalTo(usernameLabel)
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(eventsPlayedLabel.snp.bottom).offset(UserCardViewConstan.topPadding)
            make.leading.trailing.equalToSuperview().inset(UserCardViewConstan.padding)
            make.bottom.equalToSuperview().inset(UserCardViewConstan.topPadding)
        }
    }
    
    private func setupStats(with stats: UserModel) {
        // Очищаем предыдущие данные
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        eventsPlayedLabel.text = "\(stats.plays) игр"
        
        // LVL
        let lvlView = createStatView(title: "LVL", value: "\(stats.level)")
        statsStackView.addArrangedSubview(lvlView)
        
        // MVP
        let mvpView = createStatView(title: "MVP", value: "\(stats.mvpCount)")
        statsStackView.addArrangedSubview(mvpView)
        
        // MVP N
        let mvpNominationsView = createStatView(title: "MVP N", value: "\(stats.mvpNominations)")
        statsStackView.addArrangedSubview(mvpNominationsView)
        
        // ATT
        let attView = createStatView(title: "ATT", value: "na")
        statsStackView.addArrangedSubview(attView)
    }
    
    private func createStatView(title: String, value: String) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .yellow
        titleLabel.textAlignment = .center
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = .yellow
        valueLabel.textAlignment = .center
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return container
    }
}

fileprivate struct UserCardViewConstan {
    static let cardColor: UIColor = .mediumGreen
    static let padding: CGFloat = 10
    static let topPadding: CGFloat = 10
    static let heightImage: CGFloat = 220
}
