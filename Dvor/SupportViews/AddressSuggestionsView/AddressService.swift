import UIKit

final class AddressSuggestionsView: UIView {
    
    var expectedCity: String {
        get { addressService.expectedCity }
        set { addressService.expectedCity = newValue }
    }
    
    var onAddressSelected: ((String) -> Void)?
    var onNeedsHouseNumber: ((String) -> Void)?
    var onInvalidSelection: (() -> Void)?
    
    private let addressService: AddressCompleterServiceProtocol
    private var suggestions: [SuggestionModel] = [] {
        didSet {
            isHidden = suggestions.isEmpty
            tableView.reloadData()
        }
    }
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.separatorInset = .zero
        return tv
    }()
    
    init(addressService: AddressCompleterServiceProtocol = AddressCompleterService()) {
        self.addressService = addressService
        super.init(frame: .zero)
        isHidden = true
        self.addressService.delegate = self
        setupLayout()
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func search(query: String) {
        guard !query.isEmpty else {
            clear()
            return
        }
        addressService.search(query: query)
    }
    
    func clear() {
        suggestions = []
    }
    
    private func setupLayout() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configure() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension AddressSuggestionsView: AddressCompleterServiceDelegate {
    func addressCompleterService(_ service: AddressCompleterService, didUpdateResults results: [SuggestionModel]) {
        suggestions = results
    }
    
    func addressCompleterService(_ service: AddressCompleterService, didFailWithError error: Error) {
        suggestions = []
    }
}

extension AddressSuggestionsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = suggestions[indexPath.row].title
        cell.detailTextLabel?.text = suggestions[indexPath.row].subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressService.selectAddress(at: indexPath.row) { [weak self] result in
            guard let self else { return }

            switch result {
            case .completed(let address):
                self.clear()
                self.onAddressSelected?(address)

            case .needsHouseNumber(let textToFill):
                self.onNeedsHouseNumber?(textToFill)
                self.addressService.search(query: textToFill)

            case .invalid:
                self.onInvalidSelection?()
            }
        }
    }
}
