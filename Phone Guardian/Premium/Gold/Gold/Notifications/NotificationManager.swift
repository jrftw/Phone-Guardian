// NotificationManager.swift

import Foundation
import UserNotifications
import os.log

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                os_log("Notification authorization error: %@", error.localizedDescription)
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
}
