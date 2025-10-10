import UIKit

class TabBarViewController: UITabBarController {
    
    //MARK: - Properties
    var presenter: TabBarPresenterProtocol?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarAppearance()
    }
    
    //MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.showView()
    }

    //MARK: - Generate View Controllers
    private func generateVC(model: TabBarModel) -> UINavigationController {
        let image = UIImage(systemName: model.selectedImage)
        let selectedImage = image?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(TabBarConstants.selectedColor)
        
        let unselectedImage = image?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(TabBarConstants.unSelectedColor
            .withAlphaComponent(0.5))
        
        model.vc.tabBarItem.image = unselectedImage
        model.vc.tabBarItem.selectedImage = selectedImage
        model.vc.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let navVC = UINavigationController(rootViewController: model.vc)
        navVC.setNavigationBarHidden(true, animated: true)
        
        return navVC
    }
    
    //MARK: - Set TabBar Appearance
    private func setTabBarAppearance () {
        let width = tabBar.bounds.width
        tabBar.itemWidth = width / TabBarConstants.itemsCount
        tabBar.itemPositioning = .automatic
        tabBar.backgroundColor = .black
        tabBar.isTranslucent = true
    }
}

//MARK: - Tab Bar Protocol
extension TabBarViewController: TabBarProtocol {
    func setTabbarControllers(controllers: TabBarModels) {
        viewControllers = [
//            generateVC(model: controllers.cells[0]),
//            generateVC(model: controllers.cells[1]),
            generateVC(model: controllers.cells[2]),
//            generateVC(model: controllers.cells[3]),
            generateVC(model: controllers.cells[4]),
        ]
    }
}

//MARK: - Tab Bar Constants
fileprivate struct TabBarConstants {
    static let selectedColor = UIColor(.white)
    static let unSelectedColor = Constants.Colors.inActiveColor
    static let itemsCount: CGFloat = 2
}
