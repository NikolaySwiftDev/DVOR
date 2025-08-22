import UIKit
import SnapKit

final class UserTableViewCell: UITableViewCell {
    
    static let identifier = "UserTableViewCell"

    // MARK: - UI Elements

    private let indexLabel = UILabel.init(textColor: .white)
    
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
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor.darkGray
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        return progress
    }()
    
    private let positionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemTeal
        return label
    }()
    
    private let ticketImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "ticket.fill"))
        iv.tintColor = .systemGreen
        return iv
    }()
    
    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
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
        
        contentView.addSubview(indexLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(positionLabel)
        contentView.addSubview(ticketImageView)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(rightArrowImageView)
    }

    private func setupConstraints() {
        indexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(ticketImageView.snp.leading).offset(-8)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(nameLabel)
            make.height.equalTo(4)
        }

        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(8)
        }

        ticketImageView.snp.makeConstraints { make in
            make.trailing.equalTo(checkmarkImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
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
    func configure(with model: UserModel, index: Int) {
        indexLabel.text = "\(index + 1)"
        nameLabel.text = model.name
        
        positionLabel.text = model.position
        ticketImageView.isHidden = !model.hasTicket
        checkmarkImageView.isHidden = !model.isChecked
        progressView.progress = model.progress
        
        if let data = model.image {
            avatarImageView.image = UIImage(data: data)
        } else {
            avatarImageView.image = UIImage(systemName: "photo.circle")
        }
        
        switch model.progress {
        case 0...0.3:
            progressView.progressTintColor = .red
        case 0.3...0.6:
            progressView.progressTintColor = .yellow
        case 0.6...1:
            progressView.progressTintColor = .green
        default:
            progressView.progressTintColor = .blue
        }
    }
}
