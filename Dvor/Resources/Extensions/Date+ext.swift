
import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = .current
        return formatter
    }()
}

extension Date {
    func formattedAsDayMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "E, d MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func formattedBirthday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: self)
    }
    
    func age() -> Int {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ru_RU")
        
        let now = Date()
        let birthComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        var age = currentComponents.year! - birthComponents.year!
        
        if (birthComponents.month! > currentComponents.month!) ||
            (birthComponents.month == currentComponents.month && birthComponents.day! > currentComponents.day!) {
            age -= 1
        }
        
        return age
    }
    
    func isAdult() -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        
        guard let age = calendar.dateComponents([.year], from: self, to: currentDate).year else {
            return false
        }
        
        return age >= 3 && age <= 100
    }
}

