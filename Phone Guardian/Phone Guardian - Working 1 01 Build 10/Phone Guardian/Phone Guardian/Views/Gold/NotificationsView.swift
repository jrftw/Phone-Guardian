//
//  NotificationsView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/20/24.
//


import SwiftUI

struct NotificationsView: View {
    @State private var enableTemperatureAlerts = false
    @State private var enableBatteryAlerts = false

    var body: some View {
        Form {
            Section(header: Text("Notification Settings")) {
                Toggle("Enable Temperature Alerts", isOn: $enableTemperatureAlerts)
                Toggle("Enable Battery Alerts", isOn: $enableBatteryAlerts)
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
        .navigationTitle("Notification Kit")
    }
}