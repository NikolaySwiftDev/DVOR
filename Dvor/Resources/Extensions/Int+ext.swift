
import Foundation

extension Int {
    var placesString: String {
        guard self > 0 else {
            return "уже набран"
        }
        
        let lastDigit = self % 10
        let lastTwoDigits = self % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "еще \(self) мест"
        }
        
        switch lastDigit {
        case 1:
            return "еще \(self) место"
        case 2, 3, 4:
            return "еще \(self) места"
        default:
            return "еще \(self) мест"
        }
    }
}
