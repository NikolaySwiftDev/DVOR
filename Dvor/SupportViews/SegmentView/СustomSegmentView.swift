

import UIKit

protocol CustomSegmentViewDelegate: AnyObject {
    func didTapSegment(index: Int)
}

final class CustomSegmentView: UISegmentedControl {
    
    weak var delegate: CustomSegmentViewDelegate?
    
    override init(items: [Any]?) {
        super.init(items: items)
        selectedSegmentIndex = 0
        selectedSegmentTintColor = Constants.Colors.segmentInactive
        setTitleTextAttributes([.foregroundColor: Constants.Colors.segmentActive], for: .selected)
        setTitleTextAttributes([.foregroundColor: Constants.Colors.segmentInactive], for: .normal)
        addTarget(self, action: #selector(didTapSegment), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapSegment() {
        delegate?.didTapSegment(index: selectedSegmentIndex)
    }
}
