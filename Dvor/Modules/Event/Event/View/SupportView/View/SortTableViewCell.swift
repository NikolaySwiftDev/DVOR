

import UIKit

final class SortTableViewCell: UITableViewCell {
    
    static let id = "SortTableViewCell"
    
    private let titleLabel = UILabel.init()
    private let sortActiveImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(sortActiveImageView)
        
        sortActiveImageView.tintColor = .black
        selectionStyle = .none

        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(Constants.Constraint.verticalPadding / 2)
            make.trailing.equalTo(sortActiveImageView.snp.leading).inset(Constants.Constraint.horizPadding)
        }
        
        sortActiveImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Constants.Constraint.verticalPadding / 2)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }
    
    func configureCell(with model: SortCellModel, isSelected: Bool) {
        titleLabel.text = model.title
        sortActiveImageView.image = isSelected ?
            UIImage(systemName: "circle.inset.filled")?.withTintColor(.black) :
            UIImage(systemName: "circle")?.withTintColor(.black)
    }
}
