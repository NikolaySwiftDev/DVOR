import UIKit

final class OfflineAlertController {

    private weak var window: UIWindow?
    private var overlayView: OfflineOverlayView?

    // MARK: - Lifecycle

    func start(window: UIWindow) {
        self.window = window

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .networkStatusChanged,
            object: nil
        )

        NetworkMonitor.shared.startMonitoring()

        NetworkMonitor.shared.checkConnection { [weak self] isConnected in
            if isConnected {
                self?.hideOverlay()
            } else {
                self?.showOverlay()
            }
        }
    }

    // MARK: - Private

    @objc private func networkStatusChanged(_ notification: Notification) {
        guard let isConnected = notification.userInfo?[NetworkMonitor.isConnectedKey] as? Bool else { return }

        if isConnected {
            hideOverlay()
        } else {
            showOverlay()
        }
    }

    private func showOverlay() {
        guard overlayView == nil, let window else { return }

        let overlay = OfflineOverlayView(frame: window.bounds)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.alpha = 0
        overlay.onRetry = { [weak self] in
            self?.retryConnection()
        }

        window.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: window.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])

        overlayView = overlay

        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
        }
    }

    private func hideOverlay() {
        guard let overlay = overlayView else { return }
        overlayView = nil

        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
        })
    }

    private func retryConnection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }

            NetworkMonitor.shared.checkConnection { [weak self] isConnected in
                guard let self else { return }

                if isConnected {
                    self.hideOverlay()
                } else {
                    self.overlayView?.setLoading(false)
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
         print("Deinit OfflineAlertController")
    }
}

final class OfflineOverlayView: UIView {

    // MARK: - Callbacks

    var onRetry: (() -> Void)?

    // MARK: - Subviews

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "📡"
        label.font = .systemFont(ofSize: 40)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "network.offline_title".loc
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "network.offline_message".loc
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("network.retry".loc, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        isUserInteractionEnabled = true

        addSubview(cardView)
        cardView.addSubview(iconLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(retryButton)
        retryButton.addSubview(activityIndicator)

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),

            iconLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            iconLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            retryButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            retryButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            retryButton.heightAnchor.constraint(equalToConstant: 46),
            retryButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),

            activityIndicator.centerXAnchor.constraint(equalTo: retryButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: retryButton.centerYAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func retryTapped() {
        setLoading(true)
        onRetry?()
    }

    // MARK: - Public

    func setLoading(_ isLoading: Bool) {
        retryButton.isEnabled = !isLoading

        if isLoading {
            activityIndicator.startAnimating()
            retryButton.setTitle("", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            retryButton.setTitle("network.retry".loc, for: .normal)
        }
    }

    // MARK: - Touch blocking

    // Any touch inside the overlay (outside the retry button) is swallowed here,
    // so the app underneath can never be interacted with while offline.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view ?? self
    }
}
