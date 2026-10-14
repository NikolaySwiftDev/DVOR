
import Foundation

extension DateFormatter {
    static let shortDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    static let dayNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static func countryDayKey(countryCode: String, date: Date) -> String {
        "\(countryCode)|\(dayFormatter.string(from: date))"
    }
}

extension Date {
    func formattedAsDayMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "E, d MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func toString(format: String = "d MMMM, EEEE", locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    var shortDay: String {
        return DateFormatter.shortDay.string(from: self)
    }
    
    var shortMonth: String {
        return DateFormatter.dayNumber.string(from: self)
    }
}

