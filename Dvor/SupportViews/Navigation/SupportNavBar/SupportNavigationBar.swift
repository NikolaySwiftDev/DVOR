

import UIKit

protocol SupportNavigationBarDelegate: AnyObject {
    func backButtonTapped()
}

final class SupportNavigationBar: UIView {
    
    var titleText: String?
    weak var delegate: SupportNavigationBarDelegate?
    
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    private lazy var titleLabel = UILabel.init(text: titleText, font: .poppins(weight: .bold, size: 28))
    
    init(titleText: String? = nil) {
        self.titleText = titleText
        super.init(frame: .zero)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func backButtonTapped() {
        delegate?.backButtonTapped()
    }
}

extension SupportNavigationBar {
    func setupView() {
       addSubview(backButton)
       addSubview(titleLabel)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
            make.centerY.equalToSuperview()
            make.size.equalTo(Constants.Constraint.backButtonSize)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
