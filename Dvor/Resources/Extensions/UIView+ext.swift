
import UIKit

extension UIView {
    //show Animation
    func showViewWithAnimation(isHidden: Bool) {
        if isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }) { _ in
                self.isHidden = true
            }
        } else {
            self.alpha = 0
            self.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
    
    //Blur
    func addLightBlurBackground(style: UIBlurEffect.Style = .systemThickMaterialLight) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        insertSubview(blurView, at: 0)
    }
}
