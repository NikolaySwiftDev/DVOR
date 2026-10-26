import UIKit
import SnapKit

final class EventsMapViewController: UIViewController {

    // MARK: - Properties
    var presenter: EventsMapPresenterProtocol?

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
         AppLogger.log(#function, self)
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
        view.addSubview(mapView)
        view.addSubview(backButton)

        mapView.delegate = self
    }

    func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension EventsMapViewController: EventsMapProtocol {}

