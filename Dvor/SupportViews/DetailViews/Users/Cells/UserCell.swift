import UIKit
import SnapKit

final class UserTableViewCell: UITableViewCell {
    
    static let identifier = "UserTableViewCell"

    // MARK: - UI Elements
    private let indexLabel = UILabel.init()
    private let nameLabel = UILabel.init(font: .poppins(weight: .bold, size: .mid))
    private let positionLabel = UILabel.init()
    private let avatarImageView = UIImageView.init(cornerRadius: 20)
    private let ticketImageView = UIImageView(systemImage: "ticket.fill")
    private let soccerImage = UIImageView(systemImage: "soccerball.inverse")
    
//    private let progressView: UIProgressView = {
//        let progress = UIProgressView(progressViewStyle: .default)
//        progress.trackTintColor = UIColor.darkGray
//        progress.layer.cornerRadius = 2
//        progress.clipsToBounds = true
//        return progress
//    }()

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
        
        contentView.addSubview(indexLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
//        contentView.addSubview(progressView)
        contentView.addSubview(positionLabel)
        contentView.addSubview(ticketImageView)
        contentView.addSubview(soccerImage)
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
            make.top.equalToSuperview().offset(7)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(ticketImageView.snp.leading).offset(-8)
        }

//        progressView.snp.makeConstraints { make in
//            make.top.equalTo(nameLabel.snp.bottom).offset(4)
//            make.leading.equalTo(nameLabel)
//            make.trailing.equalTo(nameLabel)
//            make.height.equalTo(4)
//        }

        positionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(8)
        }

        ticketImageView.snp.makeConstraints { make in
            make.trailing.equalTo(soccerImage.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        soccerImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(25)
        }
    }

    // MARK: - Configuration
    func configure(with model: UserModel, index: Int) {
        indexLabel.text = "\(index + 1)"
        nameLabel.text = model.name
        
        positionLabel.text = model.position
        ticketImageView.isHidden = !model.hasTicket
        
//        progressView.isHidden = true
//        progressView.progress = model.progress
        
        if let data = model.image {
            avatarImageView.image = UIImage(data: data)
        } else {
            avatarImageView.image = UIImage(systemName: "photo.circle")
        }
        
//        switch model.progress {
//        case 0...0.3:
//            progressView.progressTintColor = .red
//        case 0.3...0.6:
//            progressView.progressTintColor = .yellow
//        case 0.6...1:
//            progressView.progressTintColor = .green
//        default:
//            progressView.progressTintColor = .blue
//        }
    }
}
