import UIKit
import SnapKit

final class HomeViewController: BaseViewController {
    
    // MARK: - Properties
    var presenter: HomePresenterProtocol?
    
    //Label
    private let titleDate = UILabel.init(font: .poppins(weight: .regular, size: .small))

    //Buttons
    private let sortButton = UIButton.createStandartButton(title: "Сортировка", titleColor: Constants.Colors.buttonActiveColor, backgroundColor: .clear, target: self, action: #selector(sortButtonTapped))
    private let filterButton = UIButton.createStandartButton(title: "Фильтры", titleColor: Constants.Colors.buttonActiveColor, backgroundColor: .clear, target: self, action: #selector(filterButtonTapped))
    
    //Collections
    private let calendarView = CustomCalendarView()
    private let eventsTableView = EventsTableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("Матчи")
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.fetchEvents()
    }
  
    override func didTapBellButton() {
        presenter?.createNewEvent()
    }
    
    override func didTapPersonButton() {
        presenter?.pushProfileVC()
    }
    
    @objc private func filterButtonTapped() {
        print(#function)
    }
    
    @objc private func sortButtonTapped() {
        print(#function)
    }
    
    deinit {
        print("deinit HomeVC")
    }
}

// MARK: - Home Protocol
extension HomeViewController: HomeProtocol {
    func success(date: String) {
        titleDate.text = "\(date), Санкт-Петербург"
        eventsTableView.events = presenter?.filteredEvents ?? []
    }
    
    func error(error: Error) {
        print("Error", error.localizedDescription)
    }
}

// MARK: - Custom Calendar and Event Delegate
extension HomeViewController: CustomCalendarViewDelegate, EventsTableViewDelegate {
    //Calendar delegate
    func didSelectDate(_ date: Date) {
        presenter?.filterEventsWithDate(date: date)
    }
    
    //Event delegate for PUSH
    func didSelectEvent(_ event: EventModel) {
        presenter?.pushDetailVC(model: event)
    }
    
    //Event delegate for REMOVE EVENT
    func removeSelectedEvent(_ eventID: String) {
        presenter?.deleteEvent(eventId: eventID)
    }
    
    //Event delegate for REFRESH EVENTS
    func didPullToRefresh() {
        presenter?.fetchEvents()
    }
}

// MARK: - Cell Location Delegate
extension HomeViewController: EventTableViewCellProtocol {
    func locationButtonTapped(location: String) {
        presenter?.showLocationOnMap(location: location)
    }
}

// MARK: - UI Setup
private extension HomeViewController {
    private func setupView() {
        view.addSubview(titleDate)
        view.addSubview(sortButton)
        view.addSubview(filterButton)
        view.addSubview(calendarView)
        view.addSubview(eventsTableView)
        

        var configurationFilter = UIButton.Configuration.plain()
        configurationFilter.image = UIImage(named: "filterEvent")
        configurationFilter.imagePadding = 8
        configurationFilter.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -4)
        filterButton.configuration = configurationFilter
        filterButton.tintColor = .black
        
        var configurationSort = UIButton.Configuration.plain()
        configurationSort.image = UIImage(named: "sortEvent")
        configurationSort.imagePadding = 8
        configurationSort.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -4)
        sortButton.configuration = configurationSort
        sortButton.tintColor = .black

        eventsTableView.delegate = self
        eventsTableView.cellDelegate = self
        calendarView.delegate = self
    }
    
    private func setupConstraints() {
        titleDate.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(HomeConstants.paddingTop)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(titleDate.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(HomeConstants.heightCV)
        }
        
        filterButton.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(HomeConstants.filterHeight)
        }

        sortButton.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.equalToSuperview().offset(Constants.Constraint.horizPadding)
            make.height.equalTo(HomeConstants.filterHeight)
        }
        
        eventsTableView.snp.makeConstraints { make in
            make.top.equalTo(filterButton.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Home Constants
fileprivate struct HomeConstants {
    static let paddingTop: CGFloat = 65
    static let heightCV: CGFloat = 70
    static let filterHeight: CGFloat = 30
}

