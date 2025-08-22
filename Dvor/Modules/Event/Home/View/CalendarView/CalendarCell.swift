import UIKit
import SnapKit

final class CalendarDateCell: UICollectionViewCell {
    static let identifier = "CalendarDateCell"

    private let dayLabel = UILabel()
    private let numberLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.masksToBounds = true

        dayLabel.font = .poppins(weight: .semiBold, size: 16)
        dayLabel.textAlignment = .center
        dayLabel.textColor = .white

        numberLabel.font = .poppins(weight: .semiBold, size: 16)
        numberLabel.textAlignment = .center
        numberLabel.textColor = .white

        contentView.addSubview(dayLabel)
        contentView.addSubview(numberLabel)
    }

    private func setupConstraints() {
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
        }

        numberLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }

    func configure(with model: CalendarDateModel) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        dayLabel.text = formatter.string(from: model.date)

        formatter.dateFormat = "d"
        numberLabel.text = formatter.string(from: model.date)

        contentView.backgroundColor = model.isSelected ?    .backgrDarkGreen.withAlphaComponent(0.8) :
                                                            .backgrDarkGreen
        
        contentView.layer.borderColor = model.isSelected ?  UIColor.mediumGreen.cgColor : UIColor.white.cgColor
        
        dayLabel.textColor = model.isSelected ? .mediumGreen : .white
        numberLabel.textColor = model.isSelected ? .mediumGreen : .white
    }
}
