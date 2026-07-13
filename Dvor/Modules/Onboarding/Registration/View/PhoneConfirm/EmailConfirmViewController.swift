//
//
//import UIKit
//
//final class EmailConfirmViewController: BaseRegistrationViewController {
//    
//    //MARK: - Properties
//    var onNext: (() -> Void)?
//    
//    private var countdownTimer: Timer?
//    private var remainingSeconds = 120
//    
//    //MARK: - UI
//    private let numberLabel = UILabel(font: .poppins(weight: .regular, size: .mid), textAlignment: .center)
//    private let repeatCodeLabel = UILabel(text: "Send again in 120 seconds", font: .poppins(weight: .regular, size: .mid), textAlignment: .center)
//    
//    //MARK: - Life cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupLayout()
//        configureEnadle(true)
//        startCountdown()
//    }
//    
//    //MARK: - Start Timer 
//    private func startCountdown() {
//        remainingSeconds = 120
//        updateRepeatLabel()
//        countdownTimer?.invalidate()
//        countdownTimer = Timer.scheduledTimer(
//               withTimeInterval: 1,
//               repeats: true
//           ) { [weak self] _ in
//               self?.updateCountdown()
//           }
//    }
//
//    //MARK: - Update Countdown
//    @objc private func updateCountdown() {
//        remainingSeconds -= 1
//        updateRepeatLabel()
//        
//        if remainingSeconds <= 0 {
//            countdownTimer?.invalidate()
//            countdownTimer = nil
//        }
//    }
//
//    //MARK: - Update Repeat Label
//    private func updateRepeatLabel() {
//        if remainingSeconds > 0 {
//            repeatCodeLabel.text = "Send again in \(remainingSeconds) seconds"
//            repeatCodeLabel.isUserInteractionEnabled = false
//        } else {
//            repeatCodeLabel.text = "Send again"
//            repeatCodeLabel.isUserInteractionEnabled = true
//        }
//    }
//
//    //MARK: - Setup Layout
//    private func setupLayout() {
//        view.addSubview(numberLabel)
//        view.addSubview(repeatCodeLabel)
//        
//        repeatCodeLabel.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(repaetButtonTapped))
//        repeatCodeLabel.addGestureRecognizer(tapGesture)
//        
//        numberLabel.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
//            make.centerY.equalToSuperview().offset(-120)
//        }
//        
//        repeatCodeLabel.snp.makeConstraints { make in
//            make.top.equalTo(numberLabel.snp.bottom).offset(Constants.Constraint.verticalPadding)
//            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
//        }
//    }
//    
//    //MARK: - Set Title With Number
//    func setTitleNumberText(with text: String) {
//        numberLabel.text = "A confirmation email has been sent to \n \(text)"
//    }
//
//    //MARK: -Next Button Action
//    override func nextButtonTapped() {
//        presenter?.checkEmailVerification()
//    }
//    
//    //MARK: - Repaet Button Action
//    @objc private func repaetButtonTapped() {
//        guard remainingSeconds <= 0 else { return }
//        presenter?.resendVerificationEmail()
//    }
//
//    deinit {
//        print("Deinit ---- EmailConfirmViewController")
//    }
//}
//
//    //MARK: - Regist Protocol
//extension EmailConfirmViewController:  RegistProtocol {
//    func hideLoading() {}
//    func showInfoInput() {}
//    func updateAvatarImage(_ image: UIImage) {}
//    func showError(_ message: String) {}
//    
//    func showSuccess() {
//        onNext?()
//    }
//    
//    func showLoading() {
//        startCountdown()
//    }
//    
//}
