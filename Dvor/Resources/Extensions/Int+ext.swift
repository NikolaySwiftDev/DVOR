
import Foundation

extension Int {
    var placesString: String {
        guard self > 0 else {
            return "places.full".loc
        }

        let lastDigit = self % 10
        let lastTwoDigits = self % 100

        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return String(format: "places.remaining.many".loc, self)
        }

        switch lastDigit {
        case 1:
            return String(format: "places.remaining.one".loc, self)
        case 2, 3, 4:
            return String(format: "places.remaining.few".loc, self)
        default:
            return String(format: "places.remaining.many".loc, self)
        }
    }
}
