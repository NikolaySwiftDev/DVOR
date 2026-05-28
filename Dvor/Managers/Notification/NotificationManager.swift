import UserNotifications

protocol NotificationManagerProtocol: AnyObject {
    // Запрос разрешения
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    
    // Создание и отправка уведомлений
    func createNotification(identifier: String, title: String, body: String, date: Date)
    
    // Управление уведомлениями
    func cancelNotification(identifier: String)

    // Проверка статуса разрешений
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void)
}

final class NotificationManager: NotificationManagerProtocol {
    
    private let center = UNUserNotificationCenter.current()

    // MARK: - Request Authorization
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }
    
    // MARK: - Schedule Notifications
    func createNotification(identifier: String, title: String, body: String, date: Date) {
        let content = createNotificationContent(title: title, body: body)
        
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        let notificationDate = Calendar.current.date(bySettingHour: 12, minute: 34, second: 0, of: dayBefore)!
        
        guard Calendar.current.isDateInToday(notificationDate) else {
            print("Notification skipped: date is today")
            return
        }
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        print(notificationDate.description)
    }
    
    // MARK: - Manage Notifications
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // MARK: - Authorization Status
    
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createNotificationContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }
    
    deinit {
        print("Deinit NotificationManager")
    }
}
