import UIKit

extension UIButton {
    static func createBackButton(
        image: UIImage = UIImage(resource: .arrowBack),
        target: Any? = nil,
        action: Selector? = nil,
        for controlEvents: UIControl.Event = .touchUpInside
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = Constants.Colors.buttonActiveColor
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: controlEvents)
        }
        
        return button
    }
    
    static func createStandartButton(
        title: String? = nil,
        titleColor: UIColor = Constants.Colors.titleColor,
        backgroundColor: UIColor = Constants.Colors.buttonInActiveColor,
        cornerRadius: CGFloat = Constants.Constraint.cornerRadius,
        target: Any? = nil,
        action: Selector? = nil,
        for controlEvents: UIControl.Event = .touchUpInside
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: controlEvents)
        }
        return button
    }
}
