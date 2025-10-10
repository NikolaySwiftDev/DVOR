import UIKit
import SnapKit

// MARK: - Delegate Protocol
protocol CustomNavigationBarDelegate: AnyObject {
    func didTapMagnifyingglassButton()
    func didTapBellButton()
    func didTapPersonButton()
}

final class CustomNavigationBar: UIView {
    
    // MARK: - Delegate
    weak var delegate: CustomNavigationBarDelegate?
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Заголовок"
        label.font = UIFont.poppins(weight: .bold, size: 24)
        label.textColor = .black
        return label
    }()
    
    let magnifyingglass = UIButton(type: .system)
    let bellButton = UIButton(type: .system)
    let personButton = UIButton(type: .system)
    
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
        
        [magnifyingglass, bellButton, personButton].forEach {
            $0.tintColor = .black
            addSubview($0)
        }
        
        magnifyingglass.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        bellButton.setBackgroundImage(UIImage(systemName: "bell"), for: .normal)
        personButton.setBackgroundImage(UIImage(systemName: "person"), for: .normal)

    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        personButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(25)
            make.right.equalToSuperview().inset(16)
        }
        
        bellButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(25)
            make.right.equalTo(personButton.snp.left).offset(-16)
        }
        
        magnifyingglass.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(25)
            make.right.equalTo(bellButton.snp.left).offset(-16)
        }
    }
    
    private func setupActions() {
        magnifyingglass.addTarget(self, action: #selector(magnifyingglassTapped), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        personButton.addTarget(self, action: #selector(personTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func magnifyingglassTapped() {
        delegate?.didTapMagnifyingglassButton()
    }
    
    @objc private func bellTapped() {
        delegate?.didTapBellButton()
    }
    
    @objc private func personTapped() {
        delegate?.didTapPersonButton()
    }
}
