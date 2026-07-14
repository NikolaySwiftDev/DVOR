import UIKit
import SnapKit

final class AuthTextFieldView: UIView, UITextFieldDelegate {

    // MARK: - Subviews
    let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.poppins(weight: .regular, size: 16)
        tf.textColor = .darkGray
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        return tf
    }()

    // MARK: - Init
    init(placeholder: String) {
        super.init(frame: .zero)
        setupView()
        configure(placeholder: placeholder)
        textField.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = Constants.Colors.tfBackColor
        layer.cornerRadius = Constants.Constraint.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor
        
        addSubview(textField)

        textField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }

    private func configure(placeholder: String) {
        textField.placeholder = placeholder
    }
    
    func updateBorderColor(_ color: UIColor = Constants.Colors.layerColor) {
        layer.borderColor = color.cgColor
    }
}

