import UIKit
import SnapKit

final class DetailSegmentContainerView: UIView {
    
    // MARK: - UI Components
    private let segmentControl = CustomSegmentView(items: DetailSegmentModel().items)
    let infoView = InfoView()
    let usersView = UsersView()
    private let commentsView = CommentsView()

    private var currentPosition: DetailSegmentViewPosition = .info

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        updateView(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        addSubview(segmentControl)
        addSubview(infoView)
        addSubview(usersView)
        addSubview(commentsView)
        
        segmentControl.delegate = self
    }
    
    // MARK: - Public Configuration
    func configureAllViews(detail: DetailModel, users: [UserModel], org: OrganizatorModel) {
        
        //User config
        usersView.configure(userModel: users, orgModel: org)
        
        //Info config
        infoView.configure(with: detail)
    }

    private func setupConstraints() {
        segmentControl.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }

        let views = [infoView, usersView, commentsView]
        views.forEach { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(segmentControl.snp.bottom).offset(16)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }

    // MARK: - View Switching
    private func updateView(animated: Bool) {
        let views = [infoView, usersView, commentsView]
        let target: UIView
        switch currentPosition {
        case .info: target = infoView
        case .users: target = usersView
        case .comments: target = commentsView
        }

        let direction: CGFloat = 1

        for view in views {
            guard view != target else { continue }

            if !view.isHidden {
                if animated {
                    UIView.animate(withDuration: 0.25, animations: {
                        view.alpha = 0
                        view.transform = CGAffineTransform(translationX: -50 * direction, y: 0)
                    }) { _ in
                        view.isHidden = true
                        view.transform = .identity
                    }
                } else {
                    view.alpha = 0
                    view.isHidden = true
                    view.transform = .identity
                }
            }
        }

        if target.isHidden {
            target.transform = CGAffineTransform(translationX: 50 * direction, y: 0)
            target.alpha = 0
            target.isHidden = false

            if animated {
                UIView.animate(
                    withDuration: 0.35,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0.5,
                    options: [.curveEaseInOut],
                    animations: {
                        target.alpha = 1
                        target.transform = .identity
                    },
                    completion: nil
                )
            } else {
                target.alpha = 1
                target.transform = .identity
            }
        }
    }

    // MARK: - External Control
    func configureInitialPosition(_ position: DetailSegmentViewPosition) {
        switch position {
        case .info: segmentControl.selectedSegmentIndex = 0
        case .users: segmentControl.selectedSegmentIndex = 1
        case .comments: segmentControl.selectedSegmentIndex = 2
        }
        currentPosition = position
        updateView(animated: false)
    }
}

// MARK: - Segment Changed Delegate
extension DetailSegmentContainerView: CustomSegmentViewDelegate {
    func didTapSegment(index: Int) {
        
        switch index {
        case 0: currentPosition = .info
        case 1: currentPosition = .users
        case 2: currentPosition = .comments
        default: break
        }
        updateView(animated: true)
    }
}

