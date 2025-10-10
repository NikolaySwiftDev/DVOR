import UIKit

extension UIImageView {
    //system Image
    convenience init(
        systemImage: String,
        tintColor: UIColor = Constants.Colors.layerColor,
        cornerRadius: CGFloat = 0
    ) {
        self.init()
        self.image = UIImage(systemName: systemImage)
        self.tintColor = tintColor
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }

    //custom Image
    convenience init(
        image: String = "",
        tintColor: UIColor = Constants.Colors.layerColor,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        cornerRadius: CGFloat
    ) {
        self.init()
        self.tintColor = tintColor
        self.contentMode = contentMode
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        
        if image != "" {
            self.image = UIImage(named: image)
        }
    }
}
