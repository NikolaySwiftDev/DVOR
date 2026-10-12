
import UIKit
import MapKit
import CoreLocation
import SnapKit

final class MapLocationPickerViewController: UIViewController {

    // MARK: - Properties

    var onLocationSelected: ((String, Double, Double) -> Void)?

    private let city: CityModel
    private let geocoder = CLGeocoder()

    private var selectedCoordinate: CLLocationCoordinate2D
    private var geocodingWorkItem: DispatchWorkItem?
    private var isResolvingAddress = false

    // MARK: - UI

    private let mapView = MKMapView()

    private let pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "soccerball.inverse"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let addressLabel =  UILabel(text: "Move the map to select a location",
                                        font: .poppins(weight: .regular, size: .small),
                                        textAlignment: .center)

    private let confirmButton = UIButton.createStandartButton(title: "Add location",backgroundColor: Constants.Colors.buttonActiveColor, target: self, action: #selector(confirmTapped))

    private let closeButton = UIButton.createBackButton(target: self, action: #selector(closeTapped))

    // MARK: - Init

    init(city: CityModel) {
        self.city = city
        self.selectedCoordinate = CLLocationCoordinate2D(
            latitude: city.latitude,
            longitude: city.longitude
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        showCityOnMap()
    }

    deinit {
        geocodingWorkItem?.cancel()
        geocoder.cancelGeocode()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(mapView)
        view.addSubview(pinImageView)
        view.addSubview(closeButton)
        view.addSubview(addressLabel)
        view.addSubview(confirmButton)

        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
    }

    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pinImageView.snp.makeConstraints { make in
            make.center.equalTo(mapView)
            make.size.equalTo(20)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(20)
        }

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(52)
        }

        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
    }
    
    private func showCityOnMap() {
        let center = CLLocationCoordinate2D(
            latitude: city.latitude,
            longitude: city.longitude
        )

        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 12_000,
            longitudinalMeters: 12_000
        )

        mapView.setRegion(region, animated: false)
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func confirmTapped() {
        guard !isResolvingAddress else { return }

        geocodingWorkItem?.cancel()
        isResolvingAddress = true
        confirmButton.isEnabled = false

        resolveAddress { [weak self] address in
            guard let self else { return }

            self.isResolvingAddress = false
            self.confirmButton.isEnabled = true

            guard let address else {
                self.showAddressError()
                return
            }

            self.onLocationSelected?(
                address,
                self.selectedCoordinate.latitude,
                self.selectedCoordinate.longitude
            )

            self.dismiss(animated: true)
        }
    }

    // MARK: - Reverse Geocoding

    private func resolveAddress(completion: ((String?) -> Void)? = nil) {
        let coordinate = mapView.centerCoordinate

        selectedCoordinate = coordinate

        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        geocoder.cancelGeocode()
        addressLabel.text = "Finding address..."

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self else { return }

                guard error == nil,
                      let placemark = placemarks?.first,
                      let street = placemark.thoroughfare,
                      !street.isEmpty else {
                    self.addressLabel.text = "Street address not found"
                    completion?(nil)
                    return
                }

                var address = street

                if let house = placemark.subThoroughfare,
                   !house.isEmpty {
                    address += ", \(house)"
                }

                self.addressLabel.text = address
                completion?(address)
            }
        }
    }

    private func showAddressError() {
        let alert = UIAlertController(
            title: "Address not found",
            message: "Move the map closer to a street or building and try again.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}

// MARK: - Map Delegate

extension MapLocationPickerViewController: MKMapViewDelegate {

    func mapView(
        _ mapView: MKMapView,
        regionDidChangeAnimated animated: Bool
    ) {
        selectedCoordinate = mapView.centerCoordinate
        geocodingWorkItem?.cancel()

        addressLabel.text = "Finding address in 1 second..."

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, !self.isResolvingAddress else { return }
            self.resolveAddress()
        }

        geocodingWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1,
            execute: workItem
        )
    }
}
