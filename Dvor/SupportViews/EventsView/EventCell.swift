import UIKit

protocol EventTableViewCellProtocol: AnyObject {
    func locationButtonTapped(location: String)
}

final class EventTableViewCell: UITableViewCell {

    weak var delegate: EventTableViewCellProtocol?
    
    private var locationText: String?
    
    static let identifier = "EventTableViewCell"

    private let containerView = UIView()
    private let timeLabel = UILabel()
    private let formatLabel = UILabel()
    private let peopleCountLabel = UILabel()
    private let locationButton = UIButton(type: .system)

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

        timeLabel.font = .poppins(weight: .semiBold, size: 16)
        timeLabel.textColor = .black
        timeLabel.textAlignment = .left

        formatLabel.font = .poppins(weight: .regular, size: .small)
        formatLabel.textColor = .black
        formatLabel.textAlignment = .left

        peopleCountLabel.font = .poppins(weight: .regular, size: .small)
        peopleCountLabel.textColor = .black
        peopleCountLabel.textAlignment = .left

        locationButton.titleLabel?.textAlignment = .left
        locationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        locationButton.titleLabel?.font = .poppins(weight: .regular, size: .small)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)

        contentView.addSubview(containerView)
        [timeLabel, formatLabel, peopleCountLabel, locationButton, avatarsStackView].forEach { view in
            containerView.addSubview(view)
        }
    }
    
    @objc private func locationButtonTapped() {
        delegate?.locationButtonTapped(location: locationText ?? "No location")
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

        locationButton.snp.makeConstraints {
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
            $0.leading.equalTo(locationButton.snp.leading)
        }

        avatarsStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalTo(formatLabel)
        }
        
        formatLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        locationButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        peopleCountLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func configure(with model: EventModel) {
        timeLabel.text = model.time
        formatLabel.text = model.formatString
        peopleCountLabel.text = model.peopleAllCount
        locationText = model.address
        
        let attributedString = NSAttributedString(
            string: model.address,
            attributes: [
                .font: UIFont.poppins(weight: .regular, size: .small),
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        locationButton.setAttributedTitle(attributedString, for: .normal)
        
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
            // Placeholder: системная иконка персоны
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
