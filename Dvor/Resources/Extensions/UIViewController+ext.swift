import UIKit

struct BaseConstants {
    static let bottomPaddingNumberPad: CGFloat = (UIScreen.main.bounds.height / 3)
    static let bottomPaddingKeyboard: CGFloat = (UIScreen.main.bounds.height / 2.7)
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
    func createTFView(text: String, tf: AuthTextFieldView) -> UIView {
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
    func checkTFIsNotEmpty(text: String, tf: AuthTextFieldView) {
        text.count == 0 ? tf.updateBorderColor(.clear) : tf.updateBorderColor()
    }

    //MARK: - Common email + password validation for Auth / Registration
    @discardableResult
    func validateEmailAndPassword(emailField: AuthTextFieldView,
                                  passwordField: AuthTextFieldView) -> Bool {
        let email = emailField.textField.text ?? ""
        let password = passwordField.textField.text ?? ""

        let isEmailValid = email.isValidEmail()
        let isPasswordValid = password.count >= 6

        isEmailValid ? emailField.updateBorderColor() : emailField.updateBorderColor(.clear)
        isPasswordValid ? passwordField.updateBorderColor() : passwordField.updateBorderColor(.clear)

        return isEmailValid && isPasswordValid
    }

    //MARK: - Next button common helpers
    func setNextButtonState(_ button: UIButton, isEnabled: Bool) {
        button.backgroundColor = isEnabled
        ? Constants.Colors.buttonActiveColor
        : Constants.Colors.buttonInActiveColor
        button.isEnabled = isEnabled
    }

    func adjustNextButtonBottom(_ button: UIButton,
                                in view: UIView,
                                isActiveTF: Bool,
                                isNumberPad: Bool = true) {
        let newInset = isActiveTF
        ? (isNumberPad ? BaseConstants.bottomPaddingNumberPad
                       : BaseConstants.bottomPaddingKeyboard)
        : Constants.Constraint.horizPadding

        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
            button.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(newInset)
            }
            view.layoutIfNeeded()
        }, completion: nil)
    }
}
