import UIKit
import SnapKit

protocol InfoViewProtocol: AnyObject {
    func mapButtonTapped()
}

final class InfoView: UIView {
    
    weak var delegate: InfoViewProtocol?
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let titleEvent = UILabel(text: "Событие",
                                     font: .poppins(weight: .bold, size: .big))
    
    // Address Section
    private let addressSectionView = UIView()
    private let addressIconLabel = UILabel(text: "📍", font: .systemFont(ofSize: 20))
    private let addressStackView = UIStackView()
    private let addressTitleLabel = UILabel(text: "Адрес", 
                                            font: .poppins(weight: .semiBold, size: .mid))
    private let titleAddress = UILabel()
    private let mapAdress = UIButton(type: .custom)
    
    // Place Section
    private let placeSectionView = UIView()
    private let placeIconLabel = UILabel(text: "🏢", font: .systemFont(ofSize: 20))
    private let placeStackView = UIStackView()
    private let placeTitleLabel = UILabel(text: "Место", 
                                         font: .poppins(weight: .semiBold, size: .mid))
    private let titlePlace = UILabel()
    
    // Date & Time Section
    private let dateTimeSectionView = UIView()
    private let dateTimeStackView = UIStackView()
    
    private let dateContainerView = UIView()
    private let dateIconLabel = UILabel(text: "📅", font: .systemFont(ofSize: 20))
    private let dateStackView = UIStackView()
    private let dateTitleLabel = UILabel(text: "Дата", 
                                         font: .poppins(weight: .semiBold, size: .mid))
    private let titleDate = UILabel.init(font: .poppins(weight: .semiBold, size: .small))
    
    private let timeContainerView = UIView()
    private let timeIconLabel = UILabel(text: "🕐", font: .systemFont(ofSize: 20))
    private let timeStackView = UIStackView()
    private let timeTitleLabel = UILabel(text: "Время", 
                                         font: .poppins(weight: .semiBold, size: .mid))
    private let titleTime = UILabel.init(font: .poppins(weight: .semiBold, size: .small))
    
    // People Count Section
    private let peopleSectionView = UIView()
    private let peopleIconLabel = UILabel(text: "👥", font: .systemFont(ofSize: 20))
    private let peopleStackView = UIStackView()
    private let peopleTitleLabel = UILabel(text: "Участники", 
                                           font: .poppins(weight: .semiBold, size: .mid))
    private let titleCountPeop = UILabel()
    
//    private let titlePrice = UILabel.init()
//    private let titleTimeGame = UILabel.init()

    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        config()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: DetailModel) {
        titleAddress.text = model.address
        titlePlace.text = model.namePlace
        titleDate.text = model.date.formattedAsDayMonthYear()
        titleTime.text = model.formattedTime
//        titlePrice.text = model.priceString
//        titleTimeGame.text = model.formattedTimeGame
        titleCountPeop.text = model.peopleAllCount
        
        // Apply accessibility
        applyAccessibility()
    }
    
    @objc private func mapButtonTapped() {
        delegate?.mapButtonTapped()
    }
}

private extension InfoView {
    private func setupView() {
        backgroundColor = Constants.Colors.backgroungColor
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // Setup Address Section
        addressSectionView.addSubview(addressIconLabel)
        addressSectionView.addSubview(addressStackView)
        addressStackView.addArrangedSubview(addressTitleLabel)
        addressStackView.addArrangedSubview(titleAddress)
        addressStackView.addArrangedSubview(mapAdress)
        
        // Setup Place Section
        placeSectionView.addSubview(placeIconLabel)
        placeSectionView.addSubview(placeStackView)
        placeStackView.addArrangedSubview(placeTitleLabel)
        placeStackView.addArrangedSubview(titlePlace)
        
        // Setup Date Section
        dateContainerView.addSubview(dateIconLabel)
        dateContainerView.addSubview(dateStackView)
        dateStackView.addArrangedSubview(dateTitleLabel)
        dateStackView.addArrangedSubview(titleDate)
        
        // Setup Time Section
        timeContainerView.addSubview(timeIconLabel)
        timeContainerView.addSubview(timeStackView)
        timeStackView.addArrangedSubview(timeTitleLabel)
        timeStackView.addArrangedSubview(titleTime)
        
        // Add date and time to date/time section
        dateTimeSectionView.addSubview(dateTimeStackView)
        dateTimeStackView.addArrangedSubview(dateContainerView)
        dateTimeStackView.addArrangedSubview(timeContainerView)
        
        // Setup People Section
        peopleSectionView.addSubview(peopleIconLabel)
        peopleSectionView.addSubview(peopleStackView)
        peopleStackView.addArrangedSubview(peopleTitleLabel)
        peopleStackView.addArrangedSubview(titleCountPeop)
        
        // Add all sections to main stack
        [titleEvent, addressSectionView, placeSectionView, dateTimeSectionView, peopleSectionView].forEach { view in
            stackView.addArrangedSubview(view)
        }
    }
    
    private func config() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // Main Stack View
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Configure section views
        configureSectionView(addressSectionView)
        configureSectionView(placeSectionView)
        configureSectionView(dateTimeSectionView)
        configureSectionView(peopleSectionView)
        
        // Address Stack
        configureVerticalStack(addressStackView, spacing: 4)
        configureLabel(addressTitleLabel, alpha: 0.7)
        configureLabel(titleAddress, alpha: 1.0, numberOfLines: 0)
        
        // Place Stack
        configureVerticalStack(placeStackView, spacing: 4)
        configureLabel(placeTitleLabel, alpha: 0.7)
        configureLabel(titlePlace, alpha: 1.0, numberOfLines: 0)
        
        // Date/Time Container Stack
        dateTimeStackView.axis = .horizontal
        dateTimeStackView.spacing = 5
        dateTimeStackView.alignment = .top
        dateTimeStackView.distribution = .fillEqually
        
        // Date Stack
        configureVerticalStack(dateStackView, spacing: 4)
        configureLabel(dateTitleLabel, alpha: 0.7)
        configureLabel(titleDate, alpha: 1.0)
        
        // Time Stack
        configureVerticalStack(timeStackView, spacing: 4)
        configureLabel(timeTitleLabel, alpha: 0.7)
        configureLabel(titleTime, alpha: 1.0)
        
        // People Stack
        configureVerticalStack(peopleStackView, spacing: 4)
        configureLabel(peopleTitleLabel, alpha: 0.7)
        configureLabel(titleCountPeop, alpha: 1.0)

        // Map Button
        mapAdress.setTitle("Показать на карте", for: .normal)
        mapAdress.setTitleColor(Constants.Colors.textColor.withAlphaComponent(0.8), for: .normal)
        mapAdress.titleLabel?.font = .poppins(weight: .medium, size: .small)
        mapAdress.contentHorizontalAlignment = .leading
        mapAdress.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        mapAdress.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
    }
    
    private func configureSectionView(_ view: UIView) {
        view.backgroundColor = Constants.Colors.textColor.withAlphaComponent(0.05)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }
    
    private func configureVerticalStack(_ stack: UIStackView, spacing: CGFloat) {
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .leading
        stack.distribution = .fill
    }
    
    private func configureLabel(_ label: UILabel, alpha: CGFloat, numberOfLines: Int = 1) {
        label.textColor = Constants.Colors.textColor.withAlphaComponent(alpha)
        label.numberOfLines = numberOfLines
    }
    
    private func applyAccessibility() {
        titleEvent.accessibilityTraits = .header
        
        addressSectionView.isAccessibilityElement = false
        titleAddress.isAccessibilityElement = true
        titleAddress.accessibilityLabel = "Адрес: \(titleAddress.text ?? "Не указано")"
        
        placeSectionView.isAccessibilityElement = false
        titlePlace.isAccessibilityElement = true
        titlePlace.accessibilityLabel = "Место: \(titlePlace.text ?? "Не указано")"
        
        dateTimeSectionView.isAccessibilityElement = false
        titleDate.accessibilityLabel = "Дата: \(titleDate.text ?? "")"
        titleTime.accessibilityLabel = "Время: \(titleTime.text ?? "")"
        
        peopleSectionView.isAccessibilityElement = false
        titleCountPeop.accessibilityLabel = "Участники: \(titleCountPeop.text ?? "")"
        
        mapAdress.accessibilityLabel = "Показать на карте"
        mapAdress.accessibilityHint = "Откроет карту с местоположением события"
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(InfoViewConstants.padding)
            make.bottom.equalToSuperview().inset(InfoViewConstants.padding)
        }
        
        // Address Section Constraints
        addressIconLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(InfoViewConstants.sectionPadding)
            make.size.equalTo(InfoViewConstants.iconSize)
        }
        
        addressStackView.snp.makeConstraints { make in
            make.leading.equalTo(addressIconLabel.snp.trailing).offset(InfoViewConstants.iconSpacing)
            make.trailing.equalToSuperview().inset(InfoViewConstants.sectionPadding)
            make.top.bottom.equalToSuperview().inset(InfoViewConstants.sectionPadding)
        }
        
        // Place Section Constraints
        placeIconLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(InfoViewConstants.sectionPadding)
            make.size.equalTo(InfoViewConstants.iconSize)
        }
        
        placeStackView.snp.makeConstraints { make in
            make.leading.equalTo(placeIconLabel.snp.trailing).offset(InfoViewConstants.iconSpacing)
            make.trailing.equalToSuperview().inset(InfoViewConstants.sectionPadding)
            make.top.bottom.equalToSuperview().inset(InfoViewConstants.sectionPadding)
        }
        
        // Date/Time Section Constraints
        dateTimeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(InfoViewConstants.sectionPadding)
        }
        
        // Date Container
        dateIconLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(InfoViewConstants.iconSize)
        }
        
        dateStackView.snp.makeConstraints { make in
            make.leading.equalTo(dateIconLabel.snp.trailing).offset(InfoViewConstants.iconSpacing)
            make.trailing.top.bottom.equalToSuperview()
        }
        
        // Time Container
        timeIconLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(InfoViewConstants.iconSize)
        }
        
        timeStackView.snp.makeConstraints { make in
            make.leading.equalTo(timeIconLabel.snp.trailing).offset(InfoViewConstants.iconSpacing)
            make.trailing.top.bottom.equalToSuperview()
        }
        
        // People Section Constraints
        peopleIconLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(InfoViewConstants.sectionPadding)
            make.size.equalTo(InfoViewConstants.iconSize)
        }
        
        peopleStackView.snp.makeConstraints { make in
            make.leading.equalTo(peopleIconLabel.snp.trailing).offset(InfoViewConstants.iconSpacing)
            make.trailing.equalToSuperview().inset(InfoViewConstants.sectionPadding)
            make.top.bottom.equalToSuperview().inset(InfoViewConstants.sectionPadding)
        }
    }
}

fileprivate struct InfoViewConstants {
    static let padding = 16
    static let sectionPadding = 12
    static let iconSize = 24
    static let iconSpacing = 12
}
