import UIKit
import SnapKit

final class OrganizatorTableViewCell: UITableViewCell {
    
    static let identifier = "OrganizatorTableViewCell"

    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let orgLabel: UILabel = {
        let label = UILabel()
        label.text = "Организатор"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemTeal
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "soccerball.inverse"))
        iv.tintColor = .systemGreen
        return iv
    }()
    
    private let rightArrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .systemGray
        return iv
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setupViews() {
        backgroundColor = UIColor.darkGreen
        selectionStyle = .none
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(orgLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(rightArrowImageView)
    }

    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(rightArrowImageView.snp.leading).offset(-12)
        }


        orgLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(8)
        }


        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalTo(rightArrowImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        rightArrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }
    }

    // MARK: - Configuration
    func configure(with name: String) {
        nameLabel.text = name

    }
}
