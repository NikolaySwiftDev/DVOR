import UIKit
import SnapKit

protocol CommentsViewDelegate: AnyObject {
    func didSendComment(text: String)
}

final class CommentsView: UIView {

    weak var delegate: CommentsViewDelegate?

    // MARK: - UI Elements
    private let tableView = UITableView()
    private let emptyLabel = UILabel(text: CommentsViewStrings.empty,
                                      font: .poppins(weight: .medium, size: .mid),
                                      textColor: Constants.Colors.inActiveColor,
                                      textAlignment: .center)

    private let inputContainerView = UIView()
    private let textField: UITextField = {
        let tf = UITextField()
        tf.font = .poppins(weight: .medium, size: .mid)
        tf.placeholder = CommentsViewStrings.placeholder
        tf.backgroundColor = Constants.Colors.tfBackColor
        tf.layer.cornerRadius = 18
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        return tf
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        btn.tintColor = Constants.Colors.buttonActiveColor
        return btn
    }()

    // MARK: - Data
    private var comments: [CommentModel] = []
    private var inputBottomConstraint: Constraint?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        config()
        setupContraints()
        subscribeToKeyboard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Configuration
    func configure(comments: [CommentModel]) {
        self.comments = comments
        emptyLabel.isHidden = !comments.isEmpty
        tableView.reloadData()

        if !comments.isEmpty {
            let lastIndex = IndexPath(row: comments.count - 1, section: 0)
            tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
        }
    }
}

private extension CommentsView {
    private func setupView() {
        backgroundColor = Constants.Colors.backgroungColor

        addSubview(tableView)
        addSubview(emptyLabel)
        addSubview(inputContainerView)

        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(sendButton)
    }

    private func config() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)

        textField.delegate = self
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    private func setupContraints() {
        inputContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
            inputBottomConstraint = make.bottom.equalToSuperview().constraint
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }

        textField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            make.height.equalTo(36)
        }

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainerView.snp.top).offset(-8)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    @objc private func sendButtonTapped() {
        sendCurrentText()
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    private func sendCurrentText() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        delegate?.didSendComment(text: text)
        textField.text = nil
    }

    // MARK: - Keyboard Handling
    private func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let window = self.window else { return }

        let convertedFrame = window.convert(keyboardFrame, to: self)
        let overlap = max(0, bounds.maxY - convertedFrame.minY)

        animateBottomOffset(-overlap, userInfo: userInfo)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        animateBottomOffset(0, userInfo: notification.userInfo)
    }

    private func animateBottomOffset(_ offset: CGFloat, userInfo: [AnyHashable: Any]?) {
        inputBottomConstraint?.update(offset: offset)

        let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let curveRaw = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension CommentsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CommentTableViewCell.identifier,
            for: indexPath
        ) as? CommentTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: comments[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension CommentsView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCurrentText()
        textField.resignFirstResponder()
        return true
    }
}

private struct CommentsViewStrings {
    static let placeholder = "comments.placeholder".loc
    static let empty = "comments.empty".loc
}
