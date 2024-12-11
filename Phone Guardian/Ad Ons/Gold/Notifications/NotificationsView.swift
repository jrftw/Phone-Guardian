// NotificationsView.swift

import SwiftUI
import UserNotifications
import os.log

struct NotificationsView: View {
    @AppStorage("enableTemperatureAlerts") private var enableTemperatureAlerts = false
    @AppStorage("temperatureThreshold") private var temperatureThreshold = 40.0
    @AppStorage("enableBatteryAlerts") private var enableBatteryAlerts = false
    @AppStorage("batteryThreshold") private var batteryThreshold = 20.0
    @State private var notificationsEnabled = false

    var body: some View {
        Form {
            Section(header: Text("Notification Settings")) {
                Toggle(isOn: $enableTemperatureAlerts) {
                    Text("Enable Temperature Alerts (\(Int(temperatureThreshold))°C)")
                }

                if enableTemperatureAlerts {
                    VStack(alignment: .leading) {
                        Text("Set Temperature Threshold: \(Int(temperatureThreshold))°C")
                            .font(.subheadline)
                        Slider(value: $temperatureThreshold, in: 20...60, step: 1)
                            .accentColor(.red)
                    }
                    .padding(.vertical)
                }

                Toggle(isOn: $enableBatteryAlerts) {
                    Text("Enable Battery Alerts (\(Int(batteryThreshold))%)")
                }

                if enableBatteryAlerts {
                    VStack(alignment: .leading) {
                        Text("Set Battery Threshold: \(Int(batteryThreshold))%")
                            .font(.subheadline)
                        Slider(value: $batteryThreshold, in: 0...100, step: 1)
                            .accentColor(.blue)
                    }
                    .padding(.vertical)
                }

                if notificationsEnabled {
                    Button(action: disableNotifications) {
                        Text("Disable All Notifications")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    }
                } else {
                    Button(action: enableNotifications) {
                        Text("Enable Notifications")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
            }

            Section(header: Text("Premium Features")) {
                if IAPManager.shared.hasGoldSubscription {
                    Text("All notifications unlocked!")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Text("Unlock all notifications with Gold")
                        .foregroundColor(.red)
                    Button(action: {
                        Task {
                            await IAPManager.shared.purchaseGold()
                        }
                    }) {
                        Text("Unlock Gold")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            checkNotificationAuthorization()
            os_log("NotificationsView appeared.")
        }
        .navigationTitle("Notification Kit")
    }

    private func enableNotifications() {
        NotificationManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                if granted {
                    os_log("Notifications enabled successfully.")
                    scheduleNotifications()
                } else {
                    os_log("Failed to enable notifications.")
                }
            }
        }
    }

    private func disableNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        notificationsEnabled = false
        enableTemperatureAlerts = false
        enableBatteryAlerts = false
        os_log("All notifications disabled.")
    }

    private func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    private func scheduleNotifications() {
        if enableTemperatureAlerts {
            scheduleTemperatureNotification()
        }
        if enableBatteryAlerts {
            scheduleBatteryNotification()
        }
    }

    private func scheduleTemperatureNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Temperature Alert"
        content.body = "Your device temperature has exceeded \(Int(temperatureThreshold))°C."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: "temperatureAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log("Failed to schedule temperature notification: %@", error.localizedDescription)
            } else {
                os_log("Temperature notification scheduled.")
            }
        }
    }

    private func scheduleBatteryNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Battery Alert"
        content.body = "Your battery level has dropped below \(Int(batteryThreshold))%."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: "batteryAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log("Failed to schedule battery notification: %@", error.localizedDescription)
            } else {
                os_log("Battery notification scheduled.")
            }
        }
    }
}
