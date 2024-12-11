//
//  NetworkMoreInfoView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/28/24.
//

import SwiftUI

struct NetworkMoreInfoView: View {
    let activeConnections: [String]
    let ipDetails: [String: String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Active Connections Section
                Text("Active Connections")
                    .font(.headline)
                InfoRow(label: "Hotspot", value: activeConnections.contains("Hotspot") ? "Yes" : "No")
                InfoRow(label: "VPN", value: activeConnections.contains("VPN") ? "Yes" : "No")
                InfoRow(label: "Wi-Fi", value: activeConnections.contains("Wi-Fi") ? "Yes" : "No")
                InfoRow(label: "Mobile", value: activeConnections.contains("Mobile") ? "Yes" : "No")

                Divider()

                // MARK: - Mobile IP Addresses Section
                Text("Mobile IP Addresses")
                    .font(.headline)
                InfoRow(label: "IP (V4)", value: "192.168.1.101")
                InfoRow(label: "Netmask", value: "255.255.255.0")
                InfoRow(label: "Broadcast", value: "192.168.1.255")
                InfoRow(label: "External IP", value: "203.0.113.1")

                Divider()

                // MARK: - Wi-Fi IP Addresses Section
                Text("Wi-Fi IP Addresses")
                    .font(.headline)
                InfoRow(label: "SSID", value: ipDetails["SSID"] ?? "N/A")
                InfoRow(label: "BSSID", value: ipDetails["BSSID"] ?? "N/A")
                InfoRow(label: "IP (V4)", value: ipDetails["IP (V4)"] ?? "N/A")
                InfoRow(label: "Netmask", value: "255.255.255.0")
                InfoRow(label: "Broadcast", value: "192.168.1.255")
                InfoRow(label: "Router", value: "192.168.1.1")
                InfoRow(label: "External IP", value: ipDetails["External IP"] ?? "N/A")

                Divider()

                // MARK: - Definitions Section
                Text("Definitions")
                    .font(.headline)

                NetworkDefinitionsView()

                Divider()

                // MARK: - Disclaimer Section
                Text("Disclaimer")
                    .font(.headline)
                Text("Some statistics may be simulated or constrained by Apple's guidelines and system limitations. Results are dependent on the device's resources and available APIs.")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
            }
            .padding()
        }
    }
}
