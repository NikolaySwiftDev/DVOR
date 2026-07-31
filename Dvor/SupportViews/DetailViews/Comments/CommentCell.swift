import UIKit
import SnapKit

final class CommentTableViewCell: UITableViewCell {

    static let identifier = "CommentTableViewCell"

    // MARK: - UI Elements
    private let avatarImageView = UIImageView(cornerRadius: 18)
    private let nameLabel = UILabel(font: .poppins(weight: .bold, size: .small))
    private let dateLabel = UILabel(font: .poppins(weight: .regular, size: .small),
                                     textColor: Constants.Colors.inActiveColor)
    
    private let texteLabel = UILabel(font: .poppins(weight: .medium, size: .mid))

    // MARK: - Init
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
        avatarImageView.image = nil
        nameLabel.text = nil
        dateLabel.text = nil
        texteLabel.text = nil
    }

    // MARK: - Layout
    private func setupViews() {
        backgroundColor = Constants.Colors.backgroungColor
        selectionStyle = .none

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(texteLabel)
    }

    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.size.equalTo(36)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(dateLabel.snp.leading).offset(-8)
        }

        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.trailing.equalToSuperview()
        }

        texteLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(1)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
    }

    // MARK: - Configuration
    func configure(with model: CommentModel) {
        nameLabel.text = model.userName
        texteLabel.text = model.text
        dateLabel.text = model.date.toString(format: "d MMM, HH:mm")

        if let data = model.userImage {
            avatarImageView.image = UIImage(data: data)
        } else {
            avatarImageView.image = UIImage(systemName: "photo.circle")
        }
    }
}
