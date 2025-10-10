import UIKit
import SnapKit

final class OrganizatorTableViewCell: UITableViewCell {
    
    static let identifier = "OrganizatorTableViewCell"

    // MARK: - UI Elements
    
    private let avatarImageView = UIImageView(cornerRadius: 20)
    
    private let nameLabel = UILabel.init()
    private let orgLabel = UILabel(text: "Организатор")
    
    private let checkmarkImageView = UIImageView(systemImage: "soccerball.inverse")
    private let rightArrowImageView = UIImageView(systemImage: "chevron.right")

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
        backgroundColor = Constants.Colors.backgroungColor
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
    func configure(with model: OrganizatorModel) {
        nameLabel.text = model.name
        
        if let data = model.image {
            avatarImageView.image = UIImage(data: data)
        } else {
            avatarImageView.image = UIImage(systemName: "photo.circle")
        }
    }
}
