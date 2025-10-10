
import Foundation

extension Int {
    var placesString: String {
        let lastDigit = self % 10
        let lastTwoDigits = self % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "\(self) мест"
        }
        
        switch lastDigit {
        case 0:
            return "набран"
        case 1:
            return "\(self) место"
        case 2, 3, 4:
            return "\(self) места"
        default:
            return "\(self) мест"
        }
    }
}
