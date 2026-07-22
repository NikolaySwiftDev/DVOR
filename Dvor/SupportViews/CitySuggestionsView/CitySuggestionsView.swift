import UIKit

final class CitySuggestionsView: UIView {
    
    //MARK: - Public
    var onCitySelected: ((CityModel) -> Void)?
    var onInvalidSelection: (() -> Void)?
    
    //MARK: - Private
    private let cityService: CityCompleterServiceProtocol
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
    
    //MARK: - Init
    init(cityService: CityCompleterServiceProtocol = CityCompleterService()) {
        self.cityService = cityService
        super.init(frame: .zero)
        isHidden = true
        self.cityService.delegate = self
        setupLayout()
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //MARK: - Public API
    func search(query: String) {
        cityService.search(query: query)
    }
    
    func clear() {
        suggestions = []
    }
    
    //MARK: - Layout
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
    
    deinit {
        // print("Deinit City VIEw")
    }
}

//MARK: - CityCompleterServiceDelegate
extension CitySuggestionsView: CityCompleterServiceDelegate {
    func cityCompleterService(_ service: CityCompleterService, didUpdateResults results: [SuggestionModel]) {
        suggestions = results
    }
    
    func cityCompleterService(_ service: CityCompleterService, didFailWithError error: Error) {
        suggestions = []
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension CitySuggestionsView: UITableViewDataSource, UITableViewDelegate {
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
        cityService.selectCity(at: indexPath.row) { [weak self] city in
            guard let self else { return }

            guard let city else {
                self.onInvalidSelection?()
                return
            }

            self.clear()
            self.onCitySelected?(city)
        }
    }
}
