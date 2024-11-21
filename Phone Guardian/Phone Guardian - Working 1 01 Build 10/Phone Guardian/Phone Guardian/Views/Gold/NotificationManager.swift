//
//  NotificationManager.swift
//  Fynnd
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//


import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            completion(granted)
        }
    }
}