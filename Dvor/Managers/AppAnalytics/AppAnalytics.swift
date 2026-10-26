import FirebaseAnalytics

enum AppAnalytics {

    static func log(_ event: Event, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }

    enum Event: String {
        case signUp = "sign_up"
        case registrationComplete = "registration_complete"
        case matchDetailView = "match_detail_view"
        case joinMatch = "join_match"
        case createMatch = "create_match"
    }
}
