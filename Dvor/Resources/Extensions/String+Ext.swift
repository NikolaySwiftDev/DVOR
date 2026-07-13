
import Foundation

extension String {
    var loc: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    func formattedAsRussianPhone() -> String {
        let cleanNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let maxLength = 11
        let trimmedNumber = String(cleanNumber.prefix(maxLength))
        
        var formattedNumber = "+7 "
        var index = trimmedNumber.startIndex
        
        if !trimmedNumber.isEmpty {
            index = trimmedNumber.index(after: index)
        }
        
        let mask = "(XXX) XXX-XX-XX"
        for ch in mask {
            if index == trimmedNumber.endIndex { break }
            
            if ch == "X" {
                formattedNumber.append(trimmedNumber[index])
                index = trimmedNumber.index(after: index)
            } else {
                formattedNumber.append(ch)
            }
        }
        
        return formattedNumber
    }
    
    func isValidRussianPhone() -> Bool {
        return self.count == 11 && self.hasPrefix("7")
    }
    
    func cleanedPhoneNumber() -> String {
        let cleanNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return String(cleanNumber.prefix(11))
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
    
    // MARK: - For firebase
    func formatPhoneNumber() -> String {
        var cleanedNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if !cleanedNumber.hasPrefix("+") {
            cleanedNumber = "+" + cleanedNumber
        }
        
        return cleanedNumber
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
