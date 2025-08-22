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
    private let miniStackView = UIStackView()
    private let titleEvent = UILabel(text: "Событие",
                                     font: .poppins(weight: .bold, size: .big),
                                     textColor: .white)
    
    private let titleAddress = UILabel(textColor: .white)
    private let mapAdress = UIButton(type: .custom)
    private let titlePlace = UILabel(textColor: .white)
    private let titleDate = UILabel(textColor: .white)
    private let titleTime = UILabel(textColor: .white)
    
    private let titlePrice = UILabel(textColor: .white)
    private let titleTimeGame = UILabel(textColor: .white)
    private let titleCountPeop = UILabel(textColor: .white)

    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        config()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: EventModel) {
        titleAddress.text = model.address
        titlePlace.text = model.namePlace
        titleDate.text = model.date.formattedAsDayMonthYear()
        titleTime.text = model.time + " ч"
        
        titlePrice.text = String(model.price) + "руб"
        titleTimeGame.text = "60мин"
        titleCountPeop.text = String(model.peopleCount) + "/16"
    }
    
    @objc private func mapButtonTapped() {
        delegate?.mapButtonTapped()
    }
}

private extension InfoView {
    private func setupView() {
        backgroundColor = UIColor.darkGreen
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        miniStackView.addArrangedSubview(titlePrice)
        miniStackView.addArrangedSubview(titleTimeGame)
        miniStackView.addArrangedSubview(titleCountPeop)
        
        [titleEvent, titleAddress, mapAdress, titlePlace, titleDate, titleTime, miniStackView].forEach { view in
            stackView.addArrangedSubview(view)
        }
    }
    
    private func config() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.distribution = .fill
        
        miniStackView.axis = .horizontal
        miniStackView.spacing = 10
        miniStackView.alignment = .leading
        miniStackView.distribution = .fill

        mapAdress.setTitle("Показать на карте", for: .normal)
        mapAdress.setTitleColor(.cyan, for: .normal)
        mapAdress.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
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
    }
}

fileprivate struct InfoViewConstants {
    static let padding = 10
}
