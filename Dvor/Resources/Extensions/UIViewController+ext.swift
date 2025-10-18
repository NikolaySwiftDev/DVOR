import UIKit


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
}
