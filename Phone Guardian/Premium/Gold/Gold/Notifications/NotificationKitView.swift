// NotificationKitView.swift

import SwiftUI
import UserNotifications
import os.log

struct NotificationKitView: View {
    @State private var tempThreshold = 40.0
    @State private var ramThreshold = 80.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Notification Thresholds")
                .font(.title)
                .bold()
                .padding(.top)

            VStack(alignment: .leading) {
                Text("Temperature Threshold: \(Int(tempThreshold))°C")
                    .font(.headline)
                Slider(value: $tempThreshold, in: 20...60, step: 1)
                    .accentColor(.red)
            }
            .padding()

            VStack(alignment: .leading) {
                Text("RAM Usage Threshold: \(Int(ramThreshold))%")
                    .font(.headline)
                Slider(value: $ramThreshold, in: 0...100, step: 1)
                    .accentColor(.blue)
            }
            .padding()

            Button(action: enableThresholdNotifications) {
                Text("Enable Notifications")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("Notification Kit")
        .onAppear {
            os_log("NotificationKitView appeared.")
        }
    }

    func enableThresholdNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                os_log("Notification permission error: %@", error.localizedDescription)
                return
            }

            if granted {
                scheduleTemperatureNotification()
                scheduleRAMNotification()
                os_log("Notifications enabled.")
            } else {
                os_log("Notification permission denied.")
            }
        }
    }

    private func scheduleTemperatureNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Temperature Alert"
        content.body = "Your device temperature has exceeded \(Int(tempThreshold))°C."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "temperatureAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log("Failed to schedule temperature notification: %@", error.localizedDescription)
            } else {
                os_log("Temperature notification scheduled.")
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
                os_log("Failed to schedule RAM notification: %@", error.localizedDescription)
            } else {
                os_log("RAM usage notification scheduled.")
            }
        }
    }
}
