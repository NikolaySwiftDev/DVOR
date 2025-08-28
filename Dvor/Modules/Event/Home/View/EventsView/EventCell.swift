
import UIKit

protocol EventTableViewCellProtocol: AnyObject {
    func locationButtonTapped(location: String)
}

final class EventTableViewCell: UITableViewCell {

    weak var delegate: EventTableViewCellProtocol?
    
    private var locationText: String?
    
    static let identifier = "EventTableViewCell"

    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let formatLabel = UILabel()
    private let ownerImageView = UIImageView()
    private let ownerLabel = UILabel()
    private let peopleCountLabel = UILabel()
    private let locationButton = UIButton(type: .system)
    private let fieldIconImageView = UIImageView()
    private let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .darkGreen
        selectionStyle = .none

        timeLabel.font = .boldSystemFont(ofSize: 16)
        timeLabel.textColor = .white

        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true

        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .systemTeal
        priceLabel.textAlignment = .right

        formatLabel.font = .systemFont(ofSize: 14)
        formatLabel.textColor = .white

        ownerImageView.layer.cornerRadius = 12
        ownerImageView.clipsToBounds = true
        ownerImageView.contentMode = .scaleAspectFill

        ownerLabel.font = .systemFont(ofSize: 14)
        ownerLabel.textColor = .white

        peopleCountLabel.font = .systemFont(ofSize: 14)
        peopleCountLabel.textColor = .white

        locationButton.setTitle("Location", for: .normal)
        locationButton.setTitleColor(.systemGreen, for: .normal)
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locationButton.tintColor = .systemGreen
        locationButton.titleLabel?.font = .systemFont(ofSize: 14)
        locationButton.semanticContentAttribute = .forceLeftToRight
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)

        fieldIconImageView.image = UIImage(systemName: "flag.fill")
        fieldIconImageView.tintColor = .systemGreen
        fieldIconImageView.contentMode = .scaleAspectFit

        arrowImageView.tintColor = .white

        [timeLabel, titleLabel, priceLabel, formatLabel, ownerImageView, ownerLabel, peopleCountLabel, locationButton, fieldIconImageView, arrowImageView].forEach { view in
            contentView.addSubview(view)
        }
    }
    
    @objc private func locationButtonTapped() {
        delegate?.locationButtonTapped(location: locationText ?? "No location")
    }

    private func setupConstraints() {
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.width.equalTo(50)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(timeLabel)
            $0.trailing.equalTo(fieldIconImageView.snp.leading).offset(-5)
        }

        fieldIconImageView.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.trailing.equalTo(priceLabel.snp.leading).offset(-2)
            $0.centerY.equalTo(titleLabel)
        }

        priceLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalTo(titleLabel)
        }

        formatLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalTo(timeLabel.snp.bottom).offset(14)
        }

        ownerImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.leading.equalTo(formatLabel.snp.trailing).offset(12)
            $0.centerY.equalTo(formatLabel)
        }

        ownerLabel.snp.makeConstraints {
            $0.leading.equalTo(ownerImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(ownerImageView)
        }

        peopleCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(ownerLabel)
            $0.trailing.equalTo(arrowImageView.snp.leading).offset(-6)
        }

        arrowImageView.snp.makeConstraints {
            $0.size.equalTo(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalTo(peopleCountLabel)
        }

        locationButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalTo(formatLabel.snp.bottom).offset(14)
            $0.bottom.equalToSuperview().inset(14)
        }
    }

    func configure(with model: EventModel) {
        timeLabel.text = model.time
        titleLabel.text = model.address
        priceLabel.text = String(format: "%.2fР", Double(model.price))
        formatLabel.text = model.format
//        ownerLabel.text = model.ownerName ?? "Unknown"
        peopleCountLabel.text = "\(model.peopleCount)"
        fieldIconImageView.image = UIImage(systemName: "")

//        if let ownerImageName = model.ownerImage {
//            ownerImageView.image = UIImage(systemName: ownerImageName)
//        }

        locationText = model.address
    }

}
