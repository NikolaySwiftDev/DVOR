
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        containerView.backgroundColor = Constants.Colors.inActiveColor.withAlphaComponent(0.3)
        containerView.layer.cornerRadius = 20
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
        [timeLabel, formatLabel, peopleCountLabel, locationButton].forEach { view in
            containerView.addSubview(view)
        }
    }
    
    @objc private func locationButtonTapped() {
        delegate?.locationButtonTapped(location: locationText ?? "No location")
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)    // Spacing сверху
            $0.leading.equalToSuperview().offset(0)
            $0.trailing.equalToSuperview().offset(0)
            $0.bottom.equalToSuperview().offset(-5) // Spacing снизу
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
            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
        
        formatLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        locationButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        peopleCountLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func configure(with model: EventModel) {
        timeLabel.text = model.time
        formatLabel.text = model.format
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
}
