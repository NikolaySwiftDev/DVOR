import UIKit
import SnapKit

protocol CustomCalendarViewDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

final class CustomCalendarView: UIView {

    weak var delegate: CustomCalendarViewDelegate?

    private var dates: [CalendarDateModel] = []
    private var collectionView: UICollectionView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDates()
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDates() {
        let calendar = Calendar.current
        let today = Date()
        dates = (0..<14).map {
            let date = calendar.date(byAdding: .day, value: $0, to: today)!
            return CalendarDateModel(date: date, isSelected: $0 == 0)
        }
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(CalendarDateCell.self, forCellWithReuseIdentifier: CalendarDateCell.identifier)

        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(60)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CustomCalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDateCell.identifier, for: indexPath) as? CalendarDateCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: dates[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CustomCalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<dates.count {
            dates[i].isSelected = (i == indexPath.item)
        }
        collectionView.reloadData()
        delegate?.didSelectDate(dates[indexPath.item].date)
    }
}
