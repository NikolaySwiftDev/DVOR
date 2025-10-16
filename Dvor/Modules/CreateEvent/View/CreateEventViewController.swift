

import UIKit

final class CreateEventViewController: UIViewController {
    var presenter: CreateEventPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.presenter?.popVC()
        }
    }
}

extension CreateEventViewController: CreateEventProtocol {
    func success() {
        
    }
    
    private func setupView() {
        view.backgroundColor = Constants.Colors.backgroungColor
    }
    
    private func setupConstraints() {
        
    }
}
