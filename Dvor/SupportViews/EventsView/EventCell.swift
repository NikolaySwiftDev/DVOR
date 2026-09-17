import UIKit

final class EventTableViewCell: UITableViewCell {
        
    static let identifier = "EventTableViewCell"

    private let containerView = UIView()
    private let timeLabel = UILabel(font: .poppins(weight: .semiBold, size: 16))
    private let formatLabel = UILabel(font: .poppins(weight: .regular, size: .small))
    private let peopleCountLabel = UILabel(font: .poppins(weight: .regular, size: .small))
    private let locationLabel = UILabel(font: .poppins(weight: .regular, size: .small))

    private let avatarsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = -10
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setupViews() {
        backgroundColor = .clear
        containerView.backgroundColor = Constants.Colors.buttonInActiveColor.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = Constants.Constraint.cornerRadius
        selectionStyle = .none

        contentView.addSubview(containerView)
        [timeLabel, formatLabel, peopleCountLabel, locationLabel, avatarsStackView].forEach { view in
            containerView.addSubview(view)
        }
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(0)
            $0.trailing.equalToSuperview().offset(0)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(20)
        }

        locationLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel.snp.trailing).offset(10)
            $0.centerY.equalTo(timeLabel)
            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
        }

        formatLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(timeLabel.snp.bottom).offset(6)
            $0.bottom.equalToSuperview().offset(-15)
        }

        peopleCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(formatLabel)
            $0.leading.equalTo(locationLabel.snp.leading)
        }

        avatarsStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalTo(formatLabel)
        }
        
        formatLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        locationLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        peopleCountLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func configure(with model: EventModel) {
        timeLabel.text = model.time
        formatLabel.text = model.formatString
        peopleCountLabel.text = model.peopleAllCount
        
        let attributedString = NSAttributedString(
            string: model.address,
            attributes: [
                .font: UIFont.poppins(weight: .regular, size: .small),
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        
        locationLabel.attributedText = attributedString
        
        switch model.peopleAllCountInt {
        case 0: peopleCountLabel.textColor = UIColor(hexString: "#10B228")
        case 1...3: peopleCountLabel.textColor = UIColor(hexString: "#B21010")
        case 4...7: peopleCountLabel.textColor = UIColor(hexString: "#DBC200")
        default: peopleCountLabel.textColor = UIColor(hexString: "#10B228")
        }
    }

    func configureAvatars(_ images: [UIImage?]) {
        avatarsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let displayImages = Array(images.prefix(3))
        guard !displayImages.isEmpty else { return }

        let size: CGFloat = 26
        let borderWidth: CGFloat = 1.5

        for (index, image) in displayImages.enumerated().reversed() {
            let avatarView = makeAvatarView(image: image, size: size, borderWidth: borderWidth)
            avatarsStackView.insertArrangedSubview(avatarView, at: 0)
            avatarView.snp.makeConstraints { $0.size.equalTo(size) }
            avatarView.layer.zPosition = CGFloat(displayImages.count - index)
        }
    }

    private func makeAvatarView(image: UIImage?, size: CGFloat, borderWidth: CGFloat) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = size / 2
        container.layer.borderWidth = borderWidth
        container.layer.borderColor = UIColor.white.cgColor
        container.clipsToBounds = true
        container.backgroundColor = UIColor.systemGray5

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        if let img = image {
            imageView.image = img
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: size * 0.5, weight: .light)
            imageView.image = UIImage(systemName: "person.fill", withConfiguration: config)
            imageView.tintColor = UIColor.systemGray3
            imageView.contentMode = .center
        }

        container.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        return container
    }
}
