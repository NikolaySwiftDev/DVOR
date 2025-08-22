

import UIKit

protocol BaseCollectionViewProtocol: AnyObject {
    func cellDidTapped(data: String, collectionType: ProfileInfo)
}

class BaseCollectionView: UICollectionView {
    
    weak var cellDelegate: BaseCollectionViewProtocol?
    
    private let layout: UICollectionViewFlowLayout
    private let collectionType: ProfileInfo
    
    init(collectionType: ProfileInfo) {
        self.layout = UICollectionViewFlowLayout()
        self.collectionType = collectionType
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 200, height: Constants.cellHeight)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.horizPadding, bottom: 0, right: 10)
        
        bounces = false
        alwaysBounceHorizontal = false
        showsHorizontalScrollIndicator = false
        
        delegate = self
        dataSource = self
        register(BaseRegistrationCell.self, forCellWithReuseIdentifier: BaseRegistrationCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}

extension BaseCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionType.model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: BaseRegistrationCell.identifier, for: indexPath) as? BaseRegistrationCell else {
            return UICollectionViewCell()
        }
        
        let data = collectionType.model[indexPath.row]
        cell.configure(with: data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = collectionType.model[indexPath.row]
        cellDelegate?.cellDidTapped(data: data, collectionType: collectionType)
    }
}
