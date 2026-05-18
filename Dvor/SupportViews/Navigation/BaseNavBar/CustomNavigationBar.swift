import UIKit
import SnapKit

// MARK: - Delegate Protocol
protocol CustomNavigationBarDelegate: AnyObject {
    func didTapPersonButton()
    func didTapAddTapped()
}

final class CustomNavigationBar: UIView {
    
    // MARK: - Delegate
    weak var delegate: CustomNavigationBarDelegate?
    
    // MARK: - UI
    private let titleLabel = UILabel.init(font: .poppins(weight: .bold, size: 28))
    private let personButton = UIButton(type: .system)
    private let addButton = UIButton(type: .system)
    private lazy var stack = UIStackView(arrangedSubviews: [ personButton, addButton])
    
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
        addSubview(stack)
        
        [personButton, addButton].forEach {
            $0.tintColor = .black
            $0.snp.makeConstraints { make in
                make.size.equalTo(25)
            }
        }

        personButton.setBackgroundImage(UIImage(systemName: "person"), for: .normal)
        addButton.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
        
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .trailing

    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.Constraint.horizPadding)
            make.centerY.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(Constants.Constraint.verticalPadding)
            make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)

        }
    }
    
    private func setupActions() {
        personButton.addTarget(self, action: #selector(personTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    @objc private func personTapped() {
        delegate?.didTapPersonButton()
    }
    
    @objc private func addTapped() {
        delegate?.didTapAddTapped()
    }
}
