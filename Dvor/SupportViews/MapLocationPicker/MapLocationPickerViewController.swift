import UIKit
import SnapKit

final class MapLocationPickerViewController: UIViewController {

    // MARK: - Properties
    var presenter: MapLocationPickerPresenterProtocol?
    var onLocationSelected: ((String, Double, Double) -> Void)? {
        get { presenter?.onLocationSelected }
        set { presenter?.onLocationSelected = newValue }
    }

    // MARK: - UI

    private let mapPickerView = MapPickerView()

    private let pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "soccerball.inverse"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let addressLabel = UILabel(
        text: "Move the map to select a location",
        font: .poppins(weight: .regular, size: .small),
        textAlignment: .center
    )

    private let confirmButton = UIButton.createStandartButton(
        title: "Add location",
        backgroundColor: Constants.Colors.buttonActiveColor,
        target: self,
        action: #selector(confirmTapped)
    )

    private let closeButton = UIButton.createBackButton(
        target: self,
        action: #selector(closeTapped)
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.view = self
        setupUI()
        setupConstraints()
        presenter?.viewDidLoad()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(mapPickerView)
        view.addSubview(pinImageView)
        view.addSubview(closeButton)
        view.addSubview(addressLabel)
        view.addSubview(confirmButton)

        mapPickerView.onRegionDidChange = { [weak self] coordinate in
            self?.presenter?.regionDidChange(center: coordinate)
        }
    }

    private func setupConstraints() {
        mapPickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pinImageView.snp.makeConstraints { make in
            make.center.equalTo(mapPickerView)
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

    // MARK: - Actions

    @objc private func closeTapped() {
        presenter?.closeTapped()
    }

    @objc private func confirmTapped() {
        presenter?.confirmTapped()
    }
    
    deinit {
        print(#function, self)
    }
}

// MARK: - MapLocationPickerViewProtocol

extension MapLocationPickerViewController: MapLocationPickerViewProtocol {

    func showRegion(center: Coordinate, meters: Double) {
        mapPickerView.showRegion(center: center, meters: meters)
    }

    func setAddressText(_ text: String) {
        addressLabel.text = text
    }

    func setConfirmEnabled(_ isEnabled: Bool) {
        confirmButton.isEnabled = isEnabled
    }
}
