import UIKit
import MapKit
import CoreLocation

protocol DetailViewDelegate: AnyObject {
    func mapButtonTapped()
}

final class DetailMapView: UIView {
    
    weak var delegate: DetailViewDelegate?
    
    // MARK: - UI
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 12
        map.clipsToBounds = true

        return map
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupGest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(with address: String) {
        loadingIndicator.startAnimating()
        geocodeAddress(address)
    }
    
    private func setupGest() {
        let gest = UITapGestureRecognizer(target: self, action: #selector(mapButtonTapped))
        self.addGestureRecognizer(gest)
    }
    
    @objc private func mapButtonTapped() {
        delegate?.mapButtonTapped()
    }
    
    // MARK: - Private
    private func setupView() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(mapView)
        addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func geocodeAddress(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else { return }
            
            let coordinate = location.coordinate
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            
            DispatchQueue.main.async {
                self.mapView.setRegion(region, animated: false)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = address
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    deinit {
        // print("Deinit map view")
    }
}
