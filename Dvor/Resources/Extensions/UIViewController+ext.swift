import UIKit
import SnapKit

struct BaseConstants {
    static let progressHeight: CGFloat = 4
    static let backButtonSize: CGFloat = 24
}

extension UIViewController {
    
    enum LoadingState {
        case add
        case delete
    }
    
    //MARK: - Add animation to View
    func hideLoadingView(with view: UIView, tag: Int, state: LoadingState) {
        switch state {
        case .add:
            let loadingView = UIView()
            loadingView.tag = tag
            loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.color = .white
            activityIndicator.startAnimating()
            
            loadingView.addSubview(activityIndicator)
            activityIndicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            view.isUserInteractionEnabled = false
            
        case .delete:
            view.isUserInteractionEnabled = true
            if let loadingView = view.viewWithTag(tag) {
                loadingView.removeFromSuperview()
            }
        }
    }
    
    //MARK: - Create TF View
    func createTFView(text: String, tf: CustomTextFieldView) -> UIView {
        let view = UIView()
        
        let label = UILabel(text: text, font: .poppins(weight: .medium, size: .small))
        
        view.addSubview(label)
        view.addSubview(tf)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(5)
        }

        tf.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
        
        return view
    }

    //MARK: - Check TF Is Not Empty
    func checkCountTFIsNotEmpty(text: String, tf: CustomTextFieldView) {
        text.count == 0 ? tf.updateBorderColor(.clear) : tf.updateBorderColor()
    }
    
    func checkPasswordTFIsNotEmpty(text: String, tf: CustomTextFieldView) {
        text.count >= 6 ? tf.updateBorderColor() :  tf.updateBorderColor(.clear)
    }
    
    func checkEmailTFisValid(text: String, tf: CustomTextFieldView) {
        !text.isValidEmail ? tf.updateBorderColor(.clear) : tf.updateBorderColor()
    }
    
    func checkTFIsNotEmpty(text: String, tf: CustomTextFieldView) {
        text.count < 4 ? tf.updateBorderColor(.clear) : tf.updateBorderColor()
    }
    
    func checkTimeTFIsNotEmpty(text: String, tf: CustomTextFieldView) {
        if text.isValidTime {
            text.count == 4 ? tf.updateBorderColor(.clear) : tf.updateBorderColor()
        } else {
            tf.updateBorderColor(.clear)
        }
    }

    //MARK: - Next button common helpers
    func setNextButtonState(_ button: UIButton, isEnabled: Bool) {
        button.backgroundColor = isEnabled
        ? Constants.Colors.buttonActiveColor
        : Constants.Colors.buttonInActiveColor
        button.isEnabled = isEnabled
    }
}

extension UIViewController {

    
    //FIX ARC
    func observeKeyboard(for constraint: Constraint, additionalInset: CGFloat = Constants.Constraint.verticalPadding) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] notification in
            self?.updateKeyboardConstraint(constraint, notification: notification, additionalInset: additionalInset)
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
            self?.updateKeyboardConstraint(constraint, notification: notification, additionalInset: additionalInset)
        }
    }

    fileprivate func updateKeyboardConstraint(_ constraint: Constraint, notification: Notification, additionalInset: CGFloat) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let window = view.window
        else { return }

        let convertedFrame = window.convert(keyboardFrame, to: view)
        let overlap = max(0, view.bounds.maxY - convertedFrame.minY)
        let extraInset = max(0, overlap - view.safeAreaInsets.bottom)
        let inset = extraInset > 0 ? extraInset + additionalInset : additionalInset

        constraint.update(inset: inset)

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }
}
