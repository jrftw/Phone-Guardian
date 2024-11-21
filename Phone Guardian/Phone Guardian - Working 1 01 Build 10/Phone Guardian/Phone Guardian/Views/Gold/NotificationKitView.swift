//
//  NotificationKitView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/19/24.
//

import SwiftUI
import UserNotifications

struct NotificationKitView: View {
    @State private var tempThreshold = 40.0
    @State private var ramThreshold = 80.0

    var body: some View {
        VStack {
            Slider(value: $tempThreshold, in: 20...60, step: 1) {
                Text("Temperature Threshold: \(Int(tempThreshold))°")
            }
            .padding(.vertical)

            Slider(value: $ramThreshold, in: 0...100, step: 1) {
                Text("RAM Usage Threshold: \(Int(ramThreshold))%")
            }
            .padding(.vertical)

            Button("Enable Notifications") {
                enableThresholdNotifications()
            }
            .padding()
        }
        .navigationTitle("Notification Kit")
    }

    func enableThresholdNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
                return
            }

            if granted {
                scheduleTemperatureNotification()
                scheduleRAMNotification()
                print("Notifications enabled.")
            } else {
                print("Notification permission denied.")
            }
        }
    }

    private func scheduleTemperatureNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Temperature Alert"
        content.body = "Your device temperature has exceeded \(Int(tempThreshold))°."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "temperatureAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule temperature notification: \(error.localizedDescription)")
            }
        }
    }

    private func scheduleRAMNotification() {
        let content = UNMutableNotificationContent()
        content.title = "RAM Usage Alert"
        content.body = "Your RAM usage has exceeded \(Int(ramThreshold))%."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "ramAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule RAM notification: \(error.localizedDescription)")
            }
        }
    }
}
