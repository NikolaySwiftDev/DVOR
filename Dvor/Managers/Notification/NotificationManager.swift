import UserNotifications

protocol NotificationManagerProtocol: AnyObject {
    // Запрос разрешения
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    
    // Создание и отправка уведомлений
    func scheduleNotification(identifier: String,title: String,body: String,timeInterval: TimeInterval,repeats: Bool)
    func scheduleNotification(identifier: String,title: String,body: String,date: Date,repeats: Bool )
    
    // Управление уведомлениями
    func cancelNotification(identifier: String)
    func cancelAllNotifications()
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void)
    
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
    
    func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        repeats: Bool
    ) {
        let content = createNotificationContent(title: title, body: body)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        date: Date,
        repeats: Bool
    ) {
        let content = createNotificationContent(title: title, body: body)
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
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
}
