import UIKit
import MapKit
import SnapKit

private final class EventAnnotation: NSObject, MKAnnotation {
    let event: EventModel

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
    }
    var title: String? { event.name }
    var subtitle: String? { event.address }

    init(event: EventModel) {
        self.event = event
    }
}

protocol EventsMapViewDelegate: AnyObject {
    func eventsMapView(_ view: EventsMapView, didSelectEvent event: EventModel)
}

final class EventsMapView: UIView {

    weak var delegate: EventsMapViewDelegate?

    private let mapView = MKMapView()
    private var didFitAnnotations = false

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(with events: [EventModel]) {
        guard !events.isEmpty else { return }
        let annotations = events.map { EventAnnotation(event: $0) }
        mapView.addAnnotations(annotations)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !didFitAnnotations, !mapView.annotations.isEmpty else { return }
        didFitAnnotations = true
        mapView.showAnnotations(mapView.annotations, animated: false)
    }

    // MARK: - Private
    private func setupView() {
        mapView.delegate = self
        addSubview(mapView)
    }

    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    deinit {
        // print(#function, self)
    }
}

// MARK: - MKMapViewDelegate
extension EventsMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cluster = annotation as? MKClusterAnnotation {
            let identifier = EventsMapViewConstants.clusterIdentifier
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: identifier)

            clusterView.annotation = cluster
            clusterView.markerTintColor = Constants.Colors.buttonActiveColor
            clusterView.glyphText = "\(cluster.memberAnnotations.count)"
            clusterView.displayPriority = .required
            clusterView.canShowCallout = false

            return clusterView
        }

        guard annotation is EventAnnotation else { return nil }

        let identifier = EventsMapViewConstants.annotationIdentifier
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        annotationView.annotation = annotation
        annotationView.markerTintColor = Constants.Colors.buttonActiveColor
        annotationView.glyphImage = UIImage(systemName: "sportscourt.fill")
        annotationView.clusteringIdentifier = EventsMapViewConstants.clusterIdentifier
        annotationView.displayPriority = .defaultHigh
        annotationView.canShowCallout = false
        annotationView.animatesWhenAdded = true

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        defer { mapView.deselectAnnotation(view.annotation, animated: false) }

        if let cluster = view.annotation as? MKClusterAnnotation {
            mapView.showAnnotations(cluster.memberAnnotations, animated: true)
            return
        }

        guard let annotation = view.annotation as? EventAnnotation else { return }
        delegate?.eventsMapView(self, didSelectEvent: annotation.event)
    }
}

fileprivate struct EventsMapViewConstants {
    static let annotationIdentifier = "EventAnnotationView"
    static let clusterIdentifier = "EventClusterView"
}
