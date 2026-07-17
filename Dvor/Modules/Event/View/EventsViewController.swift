import UIKit
import SnapKit

final class EventsViewController: BaseViewController {
    
    // MARK: - Properties
    var presenter: EventsPresenterProtocol?

    //Segment
    private let segmentView = CustomSegmentView(items: SegmentViewModel.model)
    
    //Label
    private let titleDate = UILabel.init(font: .poppins(weight: .regular, size: .small), numberOfLines: 1)

    //Buttons
    private let sortButton = UIButton.createStandartButton(title: HomeConstants.titleSort, titleColor: Constants.Colors.buttonActiveColor, backgroundColor: .clear, target: self, action: #selector(sortButtonTapped))
    private let fetchButton = UIButton.createStandartButton(title: HomeConstants.titleFetch, titleColor: Constants.Colors.buttonActiveColor, backgroundColor: .clear, target: self, action: #selector(fetchButtonTapped))
    
    //Collections
    private let calendarView = CustomCalendarView()
    private let eventsTableView = EventsTableView()
    
    //Sort View
    private let sortView = SupportEventsView(type: .sort)
    
    //Filter View
    private let filterView = SupportEventsView(type: .filter)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle(HomeConstants.titleMatch)
        configure()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.fetchEvents()
    }
  

    //MARK: - Buttons Action
    override func didTapPersonButton() {
        sortView.selectedIndex = nil
        presenter?.pushProfileVC()
    }
    
    override func didTapAddTapped() {
        sortView.selectedIndex = nil
        presenter?.pushCreateEvent()
    }
    
    @objc private func fetchButtonTapped() {
        sortView.selectedIndex = nil
        presenter?.fetchEvents()
    }
    
    @objc private func sortButtonTapped() {
        sortView.showViewWithAnimation(isHidden: false)
    }
    
    
    deinit {
        print("deinit HomeVC")
    }
}

// MARK: - Home Protocol
extension EventsViewController: EventsProtocol {
    func success(date: String) {
        titleDate.text = "\(date)"
        
        guard  let model = presenter?.filteredEvents, model.count > 0 else {
            eventsTableView.events = []
            fetchButton.isHidden = false
            return
        }
        
        fetchButton.isHidden = true
        eventsTableView.events = model
    }
    
    func updateAvatars(_ avatars: [String: Data]) {
        let images = avatars.compactMapValues { UIImage(data: $0) }
        eventsTableView.userAvatars = images
    }
    
    func error(error: Error) {
        print("Error", error.localizedDescription)
    }
}

    // MARK: - Segment View Delegate
extension EventsViewController: CustomSegmentViewDelegate {
    func didTapSegment(index: Int) {
        switch index {
        case 0:
            presenter?.sortEventsWithPredicate(predicate: .none)
        case 1:
            presenter?.sortEventsWithPredicate(predicate: .personal)
        default:
            break
        }
    }
}
    

    // MARK: - Custom Calendar and Event Delegate
extension EventsViewController: CustomCalendarViewDelegate, EventsTableViewDelegate {
    //Calendar delegate
    func didSelectDate(_ date: Date) {
        sortView.selectedIndex = nil
        presenter?.filterEventsWithDate(date: date)
    }
    
    //Event delegate for PUSH
    func didSelectEvent(_ event: EventModel) {
        sortView.selectedIndex = nil
        presenter?.pushDetailVC(model: event)
    }
    
    //Event delegate for REMOVE EVENT
    func removeSelectedEvent(_ eventID: String) {
        presenter?.deleteEvent(eventId: eventID)
    }
    
    //Event delegate for REFRESH EVENTS
    func didPullToRefresh() {
        sortView.selectedIndex = nil
        presenter?.fetchEvents()
    }
}

//MARK: -  FIlter + Sort Delegate
extension EventsViewController: SupportEventsViewDelegate {
    func closeView(type: TypeView) {
        switch type {
        case .sort:
            sortView.showViewWithAnimation(isHidden: true)
        case .filter:
            filterView.showViewWithAnimation(isHidden: true)
        }
    }
    
    func sortEvents(predicate: SortPredicate) {
        presenter?.sortEventsWithPredicate(predicate: predicate)
    }
    
    func filterEvents() {}
    
}

// MARK: - Cell Location Delegate
extension EventsViewController: EventTableViewCellProtocol {
    func locationButtonTapped(location: String) {
//        presenter?.showLocationOnMap(location: location)
    }
}

// MARK: - UI Setup
private extension EventsViewController {
    private func setupView() {
        view.addSubview(segmentView)
        view.addSubview(titleDate)
        view.addSubview(sortButton)
        view.addSubview(fetchButton)
        view.addSubview(calendarView)
        view.addSubview(eventsTableView)
        view.addSubview(filterView)
        view.addSubview(sortView)
    }
    
    private func configure() {
        eventsTableView.delegate = self
        eventsTableView.cellDelegate = self
        calendarView.delegate = self
        sortView.delegate = self
        filterView.delegate = self
        segmentView.delegate = self

        var configurationFilter = UIButton.Configuration.plain()
        configurationFilter.image = UIImage(systemName: HomeConstants.imageFetch)
        configurationFilter.imagePadding = 8
        fetchButton.configuration = configurationFilter
        fetchButton.tintColor = .black
        
        var configurationSort = UIButton.Configuration.plain()
        configurationSort.image = UIImage(named: HomeConstants.imageSort)
        configurationSort.imagePadding = 8
        sortButton.configuration = configurationSort
        sortButton.tintColor = .black
        
        sortView.isHidden = true
        filterView.isHidden = true

    }
    
    private func setupConstraints() {
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(HomeConstants.paddingTop)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.segmentHeight)
        }
        
        titleDate.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(titleDate.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(HomeConstants.heightCV)
        }
        
        fetchButton.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.trailing.equalToSuperview()
            make.height.equalTo(HomeConstants.filterHeight)
        }

        sortButton.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.equalToSuperview()
            make.height.equalTo(HomeConstants.filterHeight)
        }
        
        eventsTableView.snp.makeConstraints { make in
            make.top.equalTo(fetchButton.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        filterView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        sortView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Home Constants
fileprivate struct HomeConstants {
    static let paddingTop: CGFloat = 65
    static let heightCV: CGFloat = 70
    static let filterHeight: CGFloat = 30
    
    static let imageSort = "sortEvent"
    static let imageFetch = "arrow.triangle.2.circlepath"
    
    static let titleSort = "matches.title_sort".loc
    static let titleFetch = "matches.title_refresh".loc
    static let titleMatch = "matches.title".loc
}

