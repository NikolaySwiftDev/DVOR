
import Foundation

extension String {
//    func isValidEmail() -> Bool {
//        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
//    }
    
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
    
    // MARK: - Для firebase
    func formatPhoneNumber() -> String {
        var cleanedNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if !cleanedNumber.hasPrefix("+") {
            cleanedNumber = "+" + cleanedNumber
        }
        
        return cleanedNumber
    }
}
