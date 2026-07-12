import UIKit
import SnapKit

final class OnboardingPageViewController: UIViewController {

    // MARK: - UI
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(weight: .bold, size: .big)
        label.textColor = Constants.Colors.textColor
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .poppins(weight: .regular, size: .mid)
        label.textColor = Constants.Colors.inActiveColor
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    private lazy var stack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [emojiLabel, titleLabel, subtitleLabel])
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 16
        return sv
    }()

    // MARK: - Init

    init(page: OnboardingPage) {
        super.init(nibName: nil, bundle: nil)
        emojiLabel.text = page.emoji
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.backgroungColor
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding * 2)
        }
    }
}

import UIKit
import SnapKit


// MARK: - WelcomeOnboardingViewController
final class WelcomeOnboardingViewController: UIViewController {

    // MARK: - Properties

    var presenter: MainCoordinatePresenter?

    private let pages = OnboardingPage.pages
    private var currentIndex = 0

    private lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()

    // MARK: - UI

    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "ДВОР"
        label.font = .poppins(weight: .bold, size: .big)
        label.textColor = Constants.Colors.textColor
        label.textAlignment = .center
        return label
    }()

    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Skip".loc, for: .normal)
        btn.setTitleColor(Constants.Colors.inActiveColor, for: .normal)
        btn.titleLabel?.font = .poppins(weight: .semiBold, size: .small)
        return btn
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = Constants.Colors.buttonActiveColor
        pc.pageIndicatorTintColor = Constants.Colors.buttonInActiveColor
        pc.isUserInteractionEnabled = false
        return pc
    }()

    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Далее", for: .normal)
        btn.setTitleColor(Constants.Colors.titleColor, for: .normal)
        btn.backgroundColor = Constants.Colors.buttonActiveColor
        btn.layer.cornerRadius = Constants.Constraint.cornerRadius
        btn.titleLabel?.font = .poppins(weight: .semiBold, size: .small)
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.backgroungColor
        setupPageVC()
        setupUI()
        setupActions()
        updateState(animated: false)
    }

    // MARK: - Setup

    private func setupPageVC() {
        guard let first = makePageVC(at: 0) else { return }
        pageVC.setViewControllers([first], direction: .forward, animated: false)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
    }

    private func setupUI() {
        pageControl.numberOfPages = pages.count

        view.addSubview(logoLabel)
        view.addSubview(skipButton)
        view.addSubview(pageControl)
        view.addSubview(actionButton)

        pageVC.view.snp.makeConstraints { make in
            make.top.equalTo(logoLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top).offset(-8)
        }

        logoLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

        skipButton.snp.makeConstraints { make in
            make.centerY.equalTo(logoLabel)
            make.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(actionButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }

        actionButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
            make.height.equalTo(Constants.Constraint.buttonHeight)
        }
    }

    private func setupActions() {
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
    }

    // MARK: - Navigation

    @objc private func actionTapped() {
        let isLast = currentIndex == pages.count - 1
        if isLast {
            finish()
        } else {
            let next = currentIndex + 1
            guard let vc = makePageVC(at: next) else { return }
            pageVC.setViewControllers([vc], direction: .forward, animated: true)
            currentIndex = next
            updateState(animated: true)
        }
    }

    @objc private func finish() {
        presenter?.pushRegistVC()
    }

    // MARK: - Helpers

    private func makePageVC(at index: Int) -> UIViewController? {
        guard pages.indices.contains(index) else { return nil }
        let vc = OnboardingPageViewController(page: pages[index])
        vc.view.tag = index
        return vc
    }

    private func updateState(animated: Bool) {
        let isLast = currentIndex == pages.count - 1
        let title = isLast ? "Начать" : "Далее"
        if animated {
            UIView.transition(with: actionButton,
                              duration: 0.2,
                              options: .transitionCrossDissolve) {
                self.actionButton.setTitle(title, for: .normal)
            }
        } else {
            actionButton.setTitle(title, for: .normal)
        }
        pageControl.currentPage = currentIndex
        skipButton.isHidden = isLast
    }
}

// MARK: - UIPageViewControllerDataSource

extension WelcomeOnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let prev = viewController.view.tag - 1
        return makePageVC(at: prev)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let next = viewController.view.tag + 1
        return makePageVC(at: next)
    }
}

// MARK: - UIPageViewControllerDelegate
extension WelcomeOnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = pageViewController.viewControllers?.first else { return }
        currentIndex = current.view.tag
        updateState(animated: true)
    }
}

