
import UIKit

protocol SupportEventsViewDelegate: AnyObject {
    func closeView(type: TypeView)
    func sortEvents(predicate: SortPredicate)
    func filterEvents()
}


final class SupportEventsView: UIView {
    
    //MARK: - Properties
    weak var delegate: SupportEventsViewDelegate?
    
    private let type: TypeView
    var selectedIndex: Int? {
        didSet {
            sortTableView.reloadData()
        }
    }
    
    private let container = UIView()
    private let closeButton = UIButton.createBackButton(image: UIImage(systemName: "xmark.circle.fill")?.withTintColor(.black) ?? UIImage(), target: self, action: #selector(closeButtonTapped))
    private let sortTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        tableView.register(SortTableViewCell.self, forCellReuseIdentifier: SortTableViewCell.id)
        return tableView
    }()
    
    private lazy var labelTitle = UILabel.init(text: type.title, font: .poppins(weight: .bold, size: 18), textAlignment: .center)

    //MARK: - Init

    init(type: TypeView) {
        self.type = type
        super.init(frame: .zero)
        choiseTypeView(with: type)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Choise Type View

    private func choiseTypeView(with type: TypeView) {
        setupHeader()
        switch type {
        case .sort:
            setupSortView()
        case .filter:
            setupFilterView()
        }
    }
    
    //MARK: - Setup Header
    private func setupHeader() {
        container.backgroundColor = Constants.Colors.backgroungColor
        container.layer.cornerRadius = Constants.Constraint.cornerRadius
        
        addSubview(container)
        container.addSubview(labelTitle)
        container.addSubview(closeButton)
        
        labelTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(60)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(labelTitle)
            make.trailing.equalToSuperview().inset(Constants.Constraint.verticalPadding - 2)
            make.size.equalTo(24)
        }
        
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Constraint.verticalPadding * 3)
            make.leading.trailing.equalToSuperview()
            switch type {
            case .sort:
                make.height.equalTo(220)
            case .filter:
                make.height.equalTo(300)
            }
        }
    }
    
    //MARK: - Setup Sort View
    private func setupSortView() {
        sortTableView.dataSource = self
        sortTableView.delegate = self
        
        container.addSubview(sortTableView)
        sortTableView.snp.makeConstraints { make in
            make.top.equalTo(labelTitle.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding / 2)
            make.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Setup Filter View
    private func setupFilterView() {
        
    }

    //MARK: - Actions
    @objc private func closeButtonTapped() {
        delegate?.closeView(type: type)
    }
}

//MARK: - Delegate, DataSource
extension SupportEventsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        type.sortArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SortTableViewCell.id) as? SortTableViewCell else {
            return UITableViewCell()
        }
        let model = type.sortArray[indexPath.row]
        let isSelected = indexPath.row == selectedIndex
        cell.configureCell(with: model, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let predicate = type.sortArray[indexPath.row].predicate else { return }
        delegate?.sortEvents(predicate: predicate)
        selectedIndex = indexPath.row        
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.delegate?.closeView(type: .sort)
        }
    }
}
