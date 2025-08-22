import UIKit

extension UILabel {
    convenience init(
        text: String? = nil,
        font: UIFont = UIFont.poppins(weight: .medium, size: .mid),
        textColor: UIColor = Constants.Colors.textColor,
        textAlignment: NSTextAlignment = .left,
        adjustsFontSizeToFitWidth: Bool = true,
        numberOfLines: Int = 0
    ) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        self.numberOfLines = numberOfLines
        self.isUserInteractionEnabled = true
    }
}
