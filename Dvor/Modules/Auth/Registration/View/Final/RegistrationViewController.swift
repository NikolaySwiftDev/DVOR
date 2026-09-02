
import UIKit

final class RegistrationViewController: BaseRegistrationViewController {

    //MARK: - Properties    
    private let titleRegist = UILabel.init(text: "regist.succes_regsit".loc,
                                           font: .poppins(weight: .bold, size: .big),
                                           textColor: Constants.Colors.textColor,
                                           textAlignment: .center)
    
    private let descLabel = UILabel.init(text: "regist.moving".loc,
                                         font: .poppins(weight: .regular, size: .small),
                                         textColor: Constants.Colors.textColor,
                                         textAlignment: .center)
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Constants.Colors.textColor
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    deinit {
        // print("RegistrationViewController deinit")
    }
}


//MARK: - Extension SetupView and SetupContraints
private extension RegistrationViewController {
    private func setupView() {
        nextButton.isHidden = true

        view.backgroundColor = Constants.Colors.backgroungColor

        view.addSubview(activityIndicator)
        view.addSubview(titleRegist)
        view.addSubview(descLabel)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(50)
        }
        
        titleRegist.snp.makeConstraints { make in
            make.top.equalTo(activityIndicator.snp.bottom).offset(Constants.Constraint.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleRegist.snp.bottom).offset(Constants.Constraint.verticalPadding / 2)
            make.leading.trailing.equalToSuperview().inset(Constants.Constraint.horizPadding)
        }

    }
}
