import UIKit
import MapKit
import SnapKit

final class MapPickerView: UIView {

    // MARK: - Output

    var onRegionDidChange: ((Coordinate) -> Void)?

    // MARK: - UI

    private let mapView = MKMapView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func showRegion(center: Coordinate, meters: Double) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: center.latitude,
                longitude: center.longitude
            ),
            latitudinalMeters: meters,
            longitudinalMeters: meters
        )
        mapView.setRegion(region, animated: false)
    }

    // MARK: - Setup

    private func setup() {
        addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
    }
}

// MARK: - MKMapViewDelegate

extension MapPickerView: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        onRegionDidChange?(
            Coordinate(latitude: center.latitude, longitude: center.longitude)
        )
    }
}
