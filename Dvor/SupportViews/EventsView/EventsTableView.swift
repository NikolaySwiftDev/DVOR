import UIKit
import SnapKit

protocol EventsTableViewDelegate: AnyObject {
    func didSelectEvent(_ event: EventModel)
    func removeSelectedEvent(_ eventID: String)
    func didPullToRefresh()
}

final class EventsTableView: UIView {

    weak var delegate: EventsTableViewDelegate?
    weak var cellDelegate: EventTableViewCellProtocol?

    var events: [EventModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var userAvatars: [String: UIImage] = [:] {
        didSet {
            tableView.reloadData()
        }
    }

    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
        setupRefreshControll()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.identifier)

        addSubview(tableView)
    }
    
    private func setupRefreshControll() {
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
    }
    
    @objc private func handleRefresh() {
        guard !events.isEmpty else {
            refreshControl.endRefreshing()
            return
        }
        
        delegate?.didPullToRefresh()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension EventsTableView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier, for: indexPath) as? EventTableViewCell else {
            return UITableViewCell()
        }
        let event = events[indexPath.row]
        cell.configure(with: event)
        cell.delegate = cellDelegate

        let avatarImages: [UIImage?] = event.users
            .prefix(3)
            .compactMap { userID -> UIImage? in
                userAvatars[userID]
            }
        cell.configureAvatars(avatarImages)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectEvent(events[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".loc) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let eventId = self.events[indexPath.row].id
            self.delegate?.removeSelectedEvent(eventId)
            
            completion(true)
        }
        
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if events.isEmpty {
            tableView.refreshControl = nil
        } else {
            tableView.refreshControl = refreshControl
        }
    }
}
