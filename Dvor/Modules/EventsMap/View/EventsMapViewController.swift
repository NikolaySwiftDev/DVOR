import UIKit
import SnapKit

final class EventsMapViewController: UIViewController {

    // MARK: - Properties
    var presenter: EventsMapPresenterProtocol?

    private let titleLabel = UILabel.init(text: EventsMapConstants.title, font: .poppins(weight: .bold, size: .big), textColor: .black, textAlignment: .center)
    private let backButton = UIButton.createBackButton(target: self, action: #selector(backButtonTapped))
    private let mapView = EventsMapView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()

        mapView.configure(with: presenter?.events ?? [])
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        presenter?.popVC()
    }

    deinit {
         print(#function, self)
    }
}

// MARK: - EventsMapViewDelegate
extension EventsMapViewController: EventsMapViewDelegate {
    func eventsMapView(_ view: EventsMapView, didSelectEvent event: EventModel) {
        presenter?.pushDetailVC(model: event)
    }
}

// MARK: - UI Setup
private extension EventsMapViewController {
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(mapView)
        
        mapView.delegate = self
    }

    func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }

        mapView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension EventsMapViewController: EventsMapProtocol {}

// MARK: - Constants
fileprivate struct EventsMapConstants {
    static let title = "matches.title_map".loc
}
