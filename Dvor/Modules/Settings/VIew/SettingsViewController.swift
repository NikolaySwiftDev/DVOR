import UIKit
import SnapKit


final class SettingsViewController: UIViewController {
    
    var presenter: SettingsPresenterProtocol?
    
    private let sections: [(title: String, rows: [SettingsRow])] = [
        ("settings.section.safety".loc, [.blockedUsers]),
        ("settings.section.legal".loc, [.privacy, .terms]),
        ("settings.section.account".loc, [.signOut, .deleteAccount])
    ]
    
    private lazy var backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    
    private let titleLabel = UILabel(text: "settings.title".loc,
                                     font: .poppins(weight: .bold, size: .big),
                                     textColor: .black,
                                     textAlignment: .center)
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }
    
    deinit {
        AppLogger.log(#function, self)
    }
}

private extension SettingsViewController {
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor

        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding / 1.5)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(80)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
    

//MARK: - SettingsProtocol
extension SettingsViewController: SettingsProtocol {
    func setDeleteInProgress(_ inProgress: Bool) {
        view.isUserInteractionEnabled = !inProgress
    }
}

//MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)

        cell.textLabel?.text = row.title
        cell.textLabel?.font = .poppins(weight: .medium, size: .mid)
        cell.textLabel?.textColor = (row == .deleteAccount) ? .systemRed : .black
        cell.accessoryType = row.hasDisclosure ? .disclosureIndicator : .none
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch sections[indexPath.section].rows[indexPath.row] {
        case .blockedUsers:  presenter?.showBlockedUsers()
        case .privacy:       presenter?.openPrivacy()
        case .terms:         presenter?.openTerms()
        case .signOut:       presenter?.signOut()
        case .deleteAccount: presenter?.deleteAccount()
        }
    }
}
