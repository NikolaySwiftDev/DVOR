
import UIKit



final class BaseRegistrationCell: UICollectionViewCell {
    static let identifier = "BaseRegistrationCell"
    
    private let titleLabel = UILabel.init(font: .poppins(weight: .regular, size: .small), textAlignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Constants.Colors.buttonActiveColor : Constants.Colors.buttonInActiveColor
            titleLabel.textColor = isSelected ? Constants.Colors.titleColor : Constants.Colors.textColor
        }
    }
    
    private func setupUI() {
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = Constants.Colors.buttonInActiveColor
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
