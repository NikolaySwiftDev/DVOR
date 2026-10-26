import Foundation

// MARK: - View Protocol

protocol MapLocationPickerViewProtocol: AnyObject {
    func showRegion(center: Coordinate, meters: Double)
    func setAddressText(_ text: String)
    func setConfirmEnabled(_ isEnabled: Bool)
}

// MARK: - Presenter Protocol

protocol MapLocationPickerPresenterProtocol: AnyObject {
    var view: MapLocationPickerViewProtocol? { get set }
    var onLocationSelected: ((String, Double, Double) -> Void)? { get set }

    func viewDidLoad()
    func regionDidChange(center: Coordinate)
    func confirmTapped()
    func closeTapped()
}

// MARK: - Presenter

final class MapLocationPickerPresenter: MapLocationPickerPresenterProtocol {

    // MARK: - Public

    weak var view: MapLocationPickerViewProtocol?
    var onLocationSelected: ((String, Double, Double) -> Void)?

    // MARK: - Private

    private let geocoder: ReverseGeocoding
    private let router: RouterMainProtocol

    private var selectedCoordinate: Coordinate
    private var geocodingWorkItem: DispatchWorkItem?
    private var isResolvingAddress = false

    private enum Texts {
        static let finding = "Finding address..."
        static let findingDelayed = "Finding address in 1 second..."
        static let notFound = "Street address not found"
        static let errorTitle = "Address not found"
        static let errorMessage = "Move the map closer to a street or building and try again."
    }

    private let regionSizeInMeters: Double = 12_000
    private let geocodingDelay: TimeInterval = 1

    // MARK: - Init

    init(city: CityModel, geocoder: ReverseGeocoding, router: RouterMainProtocol) {
        self.geocoder = geocoder
        self.router = router
        self.selectedCoordinate = Coordinate(
            latitude: city.latitude,
            longitude: city.longitude
        )
    }

    deinit {
        geocodingWorkItem?.cancel()
        geocoder.cancel()
        AppLogger.log(#function, self)
    }

    // MARK: - Input

    func viewDidLoad() {
        view?.showRegion(center: selectedCoordinate, meters: regionSizeInMeters)
    }

    func regionDidChange(center: Coordinate) {
        selectedCoordinate = center
        geocodingWorkItem?.cancel()

        view?.setAddressText(Texts.findingDelayed)

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, !self.isResolvingAddress else { return }
            self.resolveAddress()
        }

        geocodingWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + geocodingDelay,
            execute: workItem
        )
    }

    func confirmTapped() {
        guard !isResolvingAddress else { return }

        geocodingWorkItem?.cancel()
        isResolvingAddress = true
        view?.setConfirmEnabled(false)

        resolveAddress { [weak self] address in
            guard let self else { return }

            self.isResolvingAddress = false
            self.view?.setConfirmEnabled(true)

            guard let address else {
                router.showAlertWithTitle(Texts.errorTitle)
                return
            }

            self.onLocationSelected?(
                address,
                self.selectedCoordinate.latitude,
                self.selectedCoordinate.longitude
            )

            closeTapped()
        }
    }

    func closeTapped() {
        router.popVC()
    }

    // MARK: - Reverse Geocoding

    private func resolveAddress(completion: ((String?) -> Void)? = nil) {
        geocoder.cancel()
        view?.setAddressText(Texts.finding)

        geocoder.address(for: selectedCoordinate) { [weak self] address in
            guard let self else { return }

            self.view?.setAddressText(address ?? Texts.notFound)
            completion?(address)
        }
    }
}
