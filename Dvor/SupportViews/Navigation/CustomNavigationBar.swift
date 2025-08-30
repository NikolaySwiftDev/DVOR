import UIKit
import SnapKit

// MARK: - Delegate Protocol
protocol CustomNavigationBarDelegate: AnyObject {
    func didTapCartButton()
    func didTapBellButton()
    func didTapMenuButton()
}

final class CustomNavigationBar: UIView {
    
    // MARK: - Delegate
    weak var delegate: CustomNavigationBarDelegate?
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Заголовок"
        label.font = UIFont.poppins(weight: .bold, size: 24)
        label.textColor = .white
        return label
    }()
    
    let cartButton = UIButton()
    let bellButton = UIButton()
    let menuButton = UIButton()
    
    // MARK: - Init
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupView()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    public func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(titleLabel)
        addSubview(cartButton)
        addSubview(bellButton)
        addSubview(menuButton)
        
        cartButton.setImage(UIImage(systemName: "cart"), for: .normal)
        bellButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        menuButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)

        [cartButton, bellButton, menuButton].forEach {
            $0.tintColor = .white
        }
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().inset(16)
        }
        
        bellButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(menuButton.snp.left).offset(-16)
        }
        
        cartButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(bellButton.snp.left).offset(-16)
        }
    }
    
    private func setupActions() {
        cartButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func cartTapped() {
        delegate?.didTapCartButton()
    }
    
    @objc private func bellTapped() {
        delegate?.didTapBellButton()
    }
    
    @objc private func menuTapped() {
        delegate?.didTapMenuButton()
    }
}
