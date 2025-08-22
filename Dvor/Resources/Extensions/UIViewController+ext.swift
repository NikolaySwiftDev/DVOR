import UIKit


extension UIViewController {
    
    enum LoadingState {
        case add
        case delete
    }
    
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
    
}
