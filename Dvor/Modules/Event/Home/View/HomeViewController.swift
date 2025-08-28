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
  
    override func didTapMenuButton() {
        let model = EventModel(date: date,
                               time: "20:00",
                               name: "Zaruba2",
                               format: "7x7",
                               location: "Spb",
                               address: "Avtovo5",
                               namePlace: "Sc 229",
                               price: 2000,
                               peopleCount: 0,
                               ownerName: "Nik",
                               timeGame: 120,
                               totlePeoplaCount: 12)
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
//        presenter?.pushDetailVC(model: event)
        eventID = event.id
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
            make.top.equalTo(calendarView.snp.bottom).offset(HomeConstants.paddingCVTop)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - Home Constants
fileprivate struct HomeConstants {
    static let paddingTop: CGFloat = 70
    static let paddingCVTop: CGFloat = 20
    static let heightCV: CGFloat = 60
}

fileprivate let newEvent = EventModel(date: Date.now,
                                      time: "19:00",
                                      name: "Zaruba",
                                      format: "6x6",
                                      location: "Spb",
                                      address: "Avtovo",
                                      namePlace: "Sc 229",
                                      price: 2000,
                                      peopleCount: 0,
                                      ownerName: "Nik",
                                      timeGame: 120,
                                      totlePeoplaCount: 12)

fileprivate let newEvent1 = EventModel(date: Date.now,
                                      time: "19:00",
                                      name: "Zaruba",
                                      format: "6x6",
                                      location: "Spb",
                                      address: "Avtovo",
                                      namePlace: "Sc 229",
                                      price: 2000,
                                      peopleCount: 0,
                                      ownerName: "Nik",
                                      timeGame: 120,
                                      totlePeoplaCount: 12)

fileprivate let newEvent2 = EventModel(date: Date.now,
                                      time: "20:00",
                                      name: "Zaruba2",
                                      format: "7x7",
                                      location: "Spb",
                                      address: "Avtovo5",
                                      namePlace: "Sc 229",
                                      price: 2000,
                                      peopleCount: 0,
                                      ownerName: "Nik",
                                      timeGame: 120,
                                      totlePeoplaCount: 12)
