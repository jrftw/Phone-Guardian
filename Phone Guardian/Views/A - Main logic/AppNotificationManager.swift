//
//  AppNotificationManager.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/9/24.
//


import Foundation
import UserNotifications
import os.log

class AppNotificationManager {
    static let shared = AppNotificationManager()
    private let logger = Logger(subsystem: "com.phoneguardian.appnotificationmanager", category: "AppNotificationManager")

    private init() {}

    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                self.logger.error("Notification authorization error: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }

    func scheduleInactivityNotification(in days: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Your phone needs you!"
        content.body = "Check for duplicates and view device info."
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date().addingTimeInterval(Double(days * 86400))
        let triggerTime = triggerDate.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)

        let request = UNNotificationRequest(identifier: "InactivityNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Failed to schedule inactivity notification: \(error.localizedDescription)")
            } else {
                self.logger.info("Inactivity notification scheduled in \(days) days.")
            }
        }
    }

    func cancelInactivityNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["InactivityNotification"])
    }
}