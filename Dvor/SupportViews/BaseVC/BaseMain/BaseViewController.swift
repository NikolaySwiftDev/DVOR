import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    // MARK: - UI
    private let customNavBar = CustomNavigationBar(title: "")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        customNavBar.delegate = self
    }

    // MARK: - Public API
    func setNavigationTitle(_ title: String) {
        customNavBar.setTitle(title)
    }

    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = AuthConstants.backgroundColor
        view.addSubview(customNavBar)
    }

    private func setupConstraints() {
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
    }
    
    deinit {
        print("Deinit BaseVC")
    }
}

extension BaseViewController: CustomNavigationBarDelegate {
    @objc open func didTapPersonButton() {
        print(" Кнопка нажата (по умолчанию)")
    }
    
    @objc open func  didTapAddTapped() {
        print(" Кнопка нажата (по умолчанию)")
    }
}

// MARK: - Auth Constants
fileprivate struct AuthConstants {
    static let backgroundColor = UIColor.white
    static let viewWidth: CGFloat = UIScreen.main.bounds.width
    static let cornerRadius: CGFloat = 20
}
