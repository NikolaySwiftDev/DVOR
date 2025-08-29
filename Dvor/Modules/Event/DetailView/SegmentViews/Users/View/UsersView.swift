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
    private var detailEvent: DetailModel?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        config()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(with detail: DetailModel) {
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
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
            cell.configure(with: data.name)
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
            let eventUser = data.users[userIndex]
            cell.configure(with: eventUser, index: userIndex)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = detailEvent else { return }
        if indexPath.row == 0 {
//            delegate?.orgCellTapped(data)
        } else {
//            delegate?.userCellTapped(data.users[indexPath.row - 1])
        }
    }
}
