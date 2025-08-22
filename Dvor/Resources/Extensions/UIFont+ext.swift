
import UIKit

enum FontWeight: String {
    case regular = "Regular" //400
    case medium = "Medium" //500
    case semiBold = "SemiBold" //600
    case bold = "Bold" //700
    
}

enum FontSize {
    case big, mid, small
    
    var size: CGFloat {
        switch self {
        case .big:
            28
        case .mid:
            20
        case .small:
            14
        }
    }
}

extension UIFont {
    static func poppins(weight: FontWeight, size: FontSize) -> UIFont {
        let fontName = "Poppins-\(weight.rawValue)"
        
        if let font = UIFont(name: fontName, size: size.size) {
            return font
        } else {
            print("Standart Font")
            return UIFont.systemFont(ofSize: size.size, weight: .regular)
        }
    }
    
    static func poppins(weight: FontWeight, size: CGFloat) -> UIFont {
        let fontName = "Poppins-\(weight.rawValue)"
        
        if let font = UIFont(name: fontName, size: size) {
            return font
        } else {
            print("Standart Font")
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }
}

