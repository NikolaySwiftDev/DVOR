import UIKit
import SnapKit

protocol EventsTableViewDelegate: AnyObject {
    func didSelectEvent(_ event: EventModel)
}

final class EventsTableView: UIView {

    weak var delegate: EventsTableViewDelegate?
    weak var cellDelegate: EventTableViewCellProtocol?

    var events: [EventModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private let tableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
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

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        cell.configure(with: events[indexPath.row])
        cell.delegate = cellDelegate
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectEvent(events[indexPath.row])
    }
}
