
import Foundation

extension String {
    var loc: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func formattedAsBirthDate() -> String {
        let cleanString = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        var result = ""
        for (index, character) in cleanString.enumerated() {
            if index == 2 || index == 4 {
                result.append(".")
            }
            if index >= 8 { break }
            result.append(character)
        }
        return result
    }

    // MARK: - For 12:00

    func toTimeFormat() -> String? {
        let cleanString = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard cleanString.count == 4 else { return nil }
        
        let hourString = String(cleanString.prefix(2))
        let minuteString = String(cleanString.suffix(2))
        
        guard let hour = Int(hourString),
              let minute = Int(minuteString),
              (0...23).contains(hour),
              (0...59).contains(minute) else {
            return nil
        }
        
        return "\(hourString):\(minuteString)"
    }
    
    var isValidTime: Bool {
        return toTimeFormat() != nil
    }
    
    var isValidEmail: Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: regex, options: .regularExpression) != nil
    }
    
    func formatAsTime() -> String {
        let cleanString = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        switch cleanString.count {
        case 0: return ""
        case 1: return cleanString
        case 2: return cleanString
        case 3:
            let hour = String(cleanString.prefix(1))
            let minute = String(cleanString.suffix(2))
            return "\(hour):\(minute)"
        case 4:
            let hour = String(cleanString.prefix(2))
            let minute = String(cleanString.suffix(2))
            return "\(hour):\(minute)"
        default:
            let trimmed = String(cleanString.prefix(4))
            let hour = String(trimmed.prefix(2))
            let minute = String(trimmed.suffix(2))
            return "\(hour):\(minute)"
            
        }
    }
}
