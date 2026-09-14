import Foundation

protocol CityStorageProtocol: AnyObject {
    var currentCity: CityModel? { get }
    func updateCity(_ city: CityModel)
    func clearCity()
}

final class CityStorageManager: CityStorageProtocol {

    private enum Keys {
        static let city = "firebase_auth_city"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentCity: CityModel? {
        guard let data = defaults.data(forKey: Keys.city) else { return nil }
        let model = try? JSONDecoder().decode(CityModel.self, from: data)
        print("City init is -----", model?.name)
        return model
    }

    func updateCity(_ city: CityModel) {
        do {
            let data = try JSONEncoder().encode(city)
            defaults.set(data, forKey: Keys.city)
            defaults.synchronize()
            print("City save ---", city.name)
        } catch {
            print("Encode error:", error)
        }
    }

    func clearCity() {
        defaults.removeObject(forKey: Keys.city)
        print("City delete")
    }
}
