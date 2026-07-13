

import UIKit

protocol SupportNavigationBarDelegate: AnyObject {
    func backButtonTapped()
    func actionButtonTapped()
}

final class SupportNavigationBar: UIView {
    
    weak var delegate: SupportNavigationBarDelegate?
    
    private var state: SupportNavigationBarState
    
    private let backButton = UIButton.createBackButton(target: self,
                                                       action: #selector(backButtonTapped))
    
    private lazy var actionButton = UIButton.createBackButton(image: UIImage(systemName: "info.bubble") ?? UIImage(),
                                                              target: self,
                                                              action: #selector(actionButtonTapped))
    
    private lazy var titleLabel = UILabel.init(text: state.titleText,
                                               font: .poppins(weight: .bold,
                                                              size: 28))
    
    init(state: SupportNavigationBarState) {
        self.state = state
        super.init(frame: .zero)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func backButtonTapped() {
        delegate?.backButtonTapped()
    }
    
    @objc private func actionButtonTapped() {
        delegate?.actionButtonTapped()
    }
}

extension SupportNavigationBar {
    func setupView() {
        switch state {
        case .createEvent:
            addSubview(backButton)
            addSubview(titleLabel)
            addSubview(actionButton)
            
            backButton.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
                make.centerY.equalToSuperview()
            }
            
            actionButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
                make.centerY.equalToSuperview()
                make.size.equalTo(Constants.Constraint.backButtonSize)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(60)
            }
        }
    }
}

enum SupportNavigationBarState {
    case createEvent
    
    var titleText: String {
        switch self {
        case .createEvent:
            return "Create event".loc
        }
    }
}
