

import UIKit

final class CreateEventViewController: UIViewController {
    
    var presenter: CreateEventPresenterProtocol?
    
    private let navigationBar = SupportNavigationBar(titleText: "Создание события")
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        config()
    }
}

    //MARK: - Create Event Protocol
extension CreateEventViewController: CreateEventProtocol {
    func success() {}
}

    //MARK: - Navigation Bar Delegate
extension CreateEventViewController: SupportNavigationBarDelegate {
    func backButtonTapped() {
        presenter?.popVC()
    }
}

    //MARK: - Setup UI
extension CreateEventViewController {

    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(navigationBar)
    }
    
    private func config() {
        navigationBar.delegate = self
    }
    
    private func setupConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.Constraint.backButtonSize * 1.2)
        }
    }
}
