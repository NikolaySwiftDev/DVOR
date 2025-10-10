import UIKit
import SnapKit

final class CalendarDateCell: UICollectionViewCell {
    static let identifier = "CalendarDateCell"

    private let dayLabel = UILabel()
    private let numberLabel = UILabel()
    private lazy var stack = UIStackView(arrangedSubviews: [dayLabel, numberLabel])

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
        contentView.layer.masksToBounds = true

        dayLabel.font = .poppins(weight: .semiBold, size: 16)
        dayLabel.textAlignment = .center
        dayLabel.textColor = .white

        numberLabel.font = .poppins(weight: .semiBold, size: 16)
        numberLabel.textAlignment = .center
        numberLabel.textColor = .white

        
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center
        stack.distribution = .equalCentering
        
        contentView.addSubview(stack)
    }

    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview().inset(5)
        }
    }

    func configure(with model: CalendarDateModel) {
        dayLabel.text = model.date.shortDay
        dayLabel.textColor = model.isSelected ? .black : .black
        
        numberLabel.text = model.date.shortMonth
        numberLabel.textColor = model.isSelected ? .black : .black

        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = model.isSelected ? 1.8 : 1
        contentView.layer.borderColor = model.isSelected ?
        UIColor.black.cgColor :  Constants.Colors.inActiveColor.cgColor

    }
}
