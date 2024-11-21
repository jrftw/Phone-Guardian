//
//  NetworkMoreInfoView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/18/24.
//


import SwiftUI

struct NetworkMoreInfoView: View {
    let activeConnections: [String]
    let ipDetails: [String: String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Active Connections")
                    .font(.headline)
                InfoRow(label: "Hotspot", value: activeConnections.contains("Hotspot") ? "Yes" : "No")
                InfoRow(label: "VPN", value: activeConnections.contains("VPN") ? "Yes" : "No")
                InfoRow(label: "Wi-Fi", value: activeConnections.contains("Wi-Fi") ? "Yes" : "No")
                InfoRow(label: "Mobile", value: activeConnections.contains("Mobile") ? "Yes" : "No")

                Divider()

                Text("Mobile IP Addresses")
                    .font(.headline)
                InfoRow(label: "IP (V4)", value: "192.168.1.101")
                InfoRow(label: "Netmask", value: "255.255.255.0")
                InfoRow(label: "Broadcast", value: "192.168.1.255")
                InfoRow(label: "External IP", value: "203.0.113.1")

                Divider()

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

                Text("Definitions")
                    .font(.headline)

                NetworkDefinitionsView()
            }
            .padding()
        }
    }
}

// Placeholder for definitions
struct NetworkDefinitionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            InfoRow(label: "Hotspot", value: "A personal connection tethered for sharing.")
            InfoRow(label: "VPN", value: "Virtual Private Network.")
        }
    }
}