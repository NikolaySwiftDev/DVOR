
import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = .current
        return formatter
    }()
    
    static let shortDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    static let dayNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d"
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
    
    func toString(format: String = "d MMMM, EEEE", locale: String = "ru_RU") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: locale)
        return formatter.string(from: self)
    }
    
    
    func isAdult() -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        
        guard let age = calendar.dateComponents([.year], from: self, to: currentDate).year else {
            return false
        }
        
        return age >= 3 && age <= 100
    }
    
    var shortDay: String {
        return DateFormatter.shortDay.string(from: self)
    }
    
    var shortMonth: String {
        return DateFormatter.dayNumber.string(from: self)
    }
}

