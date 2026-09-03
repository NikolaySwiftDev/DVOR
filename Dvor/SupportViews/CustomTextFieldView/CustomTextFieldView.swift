import UIKit
import SnapKit

final class CustomTextFieldView: UIView, UITextFieldDelegate {

    // MARK: - Types

    enum FieldType {
        case text
        case email
        case password
    }

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

    private let togglePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .darkGray
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        return button
    }()

    // MARK: - Properties

    private let type: FieldType

    // MARK: - Init

    init(placeholder: String, type: FieldType = .text) {
        self.type = type
        super.init(frame: .zero)

        setupView()
        configure(placeholder: placeholder)
        configureType()
        setupActions()
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

        if type == .password {
            addSubview(togglePasswordButton)
        }

        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.height.equalTo(Constants.Constraint.buttonHeight)
            make.trailing.equalToSuperview().inset(type == .password ? 50 : 12)
        }

        if type == .password {
            togglePasswordButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().inset(12)
                make.width.equalTo(31)
                make.height.equalTo(22)
            }
        }
    }

    private func configure(placeholder: String) {
        textField.placeholder = placeholder
    }

    private func configureType() {
        switch type {
        case .text:
            configureTextField()
        case .email:
            configureEmailField()
        case .password:
            configurePasswordField()
        }
    }

    private func configureTextField() {
        textField.keyboardType = .default
        textField.textContentType = .none
    }

    private func configureEmailField() {
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }

    private func configurePasswordField() {
        textField.keyboardType = .default
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }

    private func setupActions() {
        guard type == .password else { return }
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func togglePasswordVisibility() {
        textField.isSecureTextEntry.toggle()

        if let text = textField.text {
            textField.text = nil
            textField.text = text
        }

        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        togglePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Public

    func updateBorderColor(_ color: UIColor = Constants.Colors.layerColor) {
        layer.borderColor = color.cgColor
    }
}
