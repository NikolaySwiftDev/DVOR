import UIKit
import SnapKit

final class BlockedUsersViewController: UIViewController {
    
    var presenter: BlockedUsersPresenterProtocol?
    private var users: [UserModel] = []
    
    private lazy var backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    
    private let titleLabel = UILabel(text: "settings.blocked_users".loc,
                                     font: .poppins(weight: .bold, size: .mid),
                                     textColor: .black,
                                     textAlignment: .center)
    
    private let emptyLabel = UILabel(text: "settings.blocked_empty".loc,
                                     font: .poppins(weight: .medium, size: .mid),
                                     textColor: Constants.Colors.inActiveColor,
                                     textAlignment: .center)
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        presenter?.fetchBlockedUsers()
    }
    
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    deinit {
        AppLogger.log(#function, self)
    }
}

private extension BlockedUsersViewController{
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor

        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BlockedUserCell")

        emptyLabel.isHidden = true

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(spinner)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding / 1.5)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(60)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

//MARK: - BlockedUsersProtocol
extension BlockedUsersViewController: BlockedUsersProtocol {
    func show(users: [UserModel]) {
        self.users = users
        tableView.reloadData()
        emptyLabel.isHidden = !users.isEmpty
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            emptyLabel.isHidden = true
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
}

//MARK: - UITableViewDataSource
extension BlockedUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        cell.textLabel?.font = .poppins(weight: .medium, size: .mid)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: - UITableViewDelegate
extension BlockedUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = users[indexPath.row]

        let action = UIContextualAction(style: .normal, title: "settings.unblock".loc) { [weak self] _, _, completion in
            self?.presenter?.unblock(user: user)
            completion(true)
        }
        action.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [action])
    }
}
