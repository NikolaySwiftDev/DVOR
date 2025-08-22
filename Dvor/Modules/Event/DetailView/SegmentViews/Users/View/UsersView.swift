import UIKit

protocol UserCellProtocol: AnyObject {
    func userCellTapped(_ model: UserModel)
    func orgCellTapped(_ model: OrganizatorModel)
}

final class UsersView: UIView {

    weak var delegate: UserCellProtocol?
    
    // MARK: - UI
    private let tableView = UITableView()
    
    // MARK: - Data
    private var detailEvent: EventDetail?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        config()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(with detail: EventDetail) {
        self.detailEvent = detail
        tableView.reloadData()
    }
}

private extension UsersView {
    private func setupView() {
        backgroundColor = .darkGreen
        addSubview(tableView)
    }

    private func config() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.register(OrganizatorTableViewCell.self, forCellReuseIdentifier: OrganizatorTableViewCell.identifier)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate & DataSource
extension UsersView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = detailEvent?.users else { return 0 }
        return data.count + 1 // +1 для ячейки организатора
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = detailEvent else { return UITableViewCell() }

        // Первая ячейка - организатор
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: OrganizatorTableViewCell.identifier,
                for: indexPath
            ) as? OrganizatorTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: data.org)
            return cell
        }
        // Остальные ячейки - пользователи
        else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserTableViewCell.identifier,
                for: indexPath
            ) as? UserTableViewCell else {
                return UITableViewCell()
            }
            
            let userIndex = indexPath.row - 1
            let userModel = data.users[userIndex]
            cell.configure(with: userModel, index: userIndex)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = detailEvent else { return }
        if indexPath.row == 0 {
            delegate?.orgCellTapped(data.org)
        } else {
            delegate?.userCellTapped(data.users[indexPath.row - 1])
        }
    }
}
