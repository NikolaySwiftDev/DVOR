import UIKit
import SnapKit

final class HomeViewController: BaseViewController {
    
    // MARK: - Properties
    var presenter: HomePresenterProtocol?
    private let calendarView = CustomCalendarView()
    private let eventsTableView = EventsTableView()
    
    var date = Date.now
    var eventID = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("События")
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.fetchEvents()
    }

    override func didTapBellButton() {
        presenter?.deleteEvent(eventId: eventID)
    }
    
    override func didTapCartButton() {
        presenter?.addUserToEvent(idEvent: eventID)
    }
  
    override func didTapMenuButton() {
        let model = EventModel(date: date,
                               time: "20:00",
                               name: "Zaruba2",
                               format: "7x7",
                               location: "",
                               address: "Кировец",
                               namePlace: "Sc 229",
                               price: 2000,
                               ownerName: "Nik",
                               timeGame: 120,
                               totalPeopleCount: 12,
                               users: [],
                               orgId: "1234")
                               
            
        presenter?.writeEvent(model: model)
    }
    
    deinit {
        print("deinit HomeVC")
    }
}

// MARK: - Home Protocol
extension HomeViewController: HomeProtocol {
    func success() {
        eventsTableView.events = presenter?.filteredEvents ?? []
        eventID = ""
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
        self.date = date
    }
    
    //Event delegate
    func didSelectEvent(_ event: EventModel) {
        eventID = event.id
        presenter?.pushDetailVC(model: event)
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
        view.addSubview(calendarView)
        view.addSubview(eventsTableView)
        
        eventsTableView.delegate = self
        eventsTableView.cellDelegate = self
        calendarView.delegate = self
    }
    
    private func setupConstraints() {
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(HomeConstants.paddingTop)
            make.left.right.equalToSuperview()
            make.height.equalTo(HomeConstants.heightCV)
        }
        
        eventsTableView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - Home Constants
fileprivate struct HomeConstants {
    static let paddingTop: CGFloat = 70
    static let heightCV: CGFloat = 60
}

