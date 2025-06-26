//
//  BatteryInfoView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/19/24.
//

import SwiftUI
import os

struct BatteryInfoView: View {
    private let logger = Logger(subsystem: "com.phoneguardian.battery", category: "BatteryInfoView")
    @AppStorage("enableLogging") private var enableLogging: Bool = false
    @AppStorage("logs") private var logsEncoded: String = "[]" // Use a JSON string to store logs
    @State private var logs: [String] = [] // Transient state for decoded logs
    @State private var batteryLevel: Int = 0
    @State private var batteryHealth: String = "Normal" // Placeholder, use real data if available

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        _batteryLevel = State(initialValue: {
            let level = UIDevice.current.batteryLevel
            return level >= 0 ? Int(level * 100) : 0 // Default to 0% if unknown
        }())
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Battery Status Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Battery Status", icon: "battery.100")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "battery.100", label: "Battery Level", value: "\(batteryLevel)%", iconColor: batteryLevelColor())
                        ModernInfoRow(icon: "bolt", label: "Battery State", value: getBatteryState(), iconColor: .orange)
                        ModernInfoRow(icon: "heart", label: "Battery Health", value: batteryHealth, iconColor: .green)
                        ModernInfoRow(icon: "bolt.fill", label: "Fast Charging", value: supportsFastCharging() ? "Supported" : "Not Supported", iconColor: .blue)
                        ModernInfoRow(icon: "wave.3.right", label: "Wireless Charging", value: supportsWirelessCharging() ? "Supported" : "Not Supported", iconColor: .purple)
                        ModernInfoRow(icon: "stop.circle", label: "Charge Limit", value: "85%", iconColor: .red)
                        ModernInfoRow(icon: "leaf", label: "Low Power Mode", value: ProcessInfo.processInfo.isLowPowerModeEnabled ? "Enabled" : "Disabled", iconColor: .green)
                        ModernInfoRow(icon: "clock", label: "Optimized Charging", value: isOptimizedChargingEnabled() ? "Enabled" : "Disabled", iconColor: .blue)
                        ModernInfoRow(icon: "leaf.fill", label: "Clean Energy Charging", value: isCleanEnergyChargingEnabled() ? "Enabled" : "Disabled", iconColor: .green)
                        ModernInfoRow(icon: "calendar", label: "Last Full Charge", value: lastChargeToFullDate(), iconColor: .orange)
                    }
                }
                .modernCard()
                
                // Battery Usage Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Battery Usage", icon: "chart.bar")
                    
                    BatteryUsageChart(batteryLevel: $batteryLevel)
                        .frame(height: 200)
                        .modernCard(padding: 16)
                }
                
                // Logging Controls Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Logging Controls", icon: "doc.text")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: toggleLogging) {
                            HStack {
                                Image(systemName: enableLogging ? "stop.circle" : "play.circle")
                                Text(enableLogging ? "Disable Logging" : "Enable Logging")
                            }
                        }
                        .modernButton(backgroundColor: enableLogging ? .red : .green)

                        if enableLogging {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Logs Enabled: Monitoring...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logBatteryStatus()
            loadLogs()
            startBatteryLevelUpdates()
        }
    }

    // MARK: - Helper Functions

    func getBatteryState() -> String {
        switch UIDevice.current.batteryState {
        case .unknown:
            logWarning("Battery state unknown.")
            return "Unknown"
        case .unplugged:
            return "Unplugged"
        case .charging:
            return "Charging"
        case .full:
            return "Full"
        @unknown default:
            logError("Unexpected battery state.")
            return "Unknown"
        }
    }

    func supportsFastCharging() -> Bool {
        return true // Placeholder
    }

    func supportsWirelessCharging() -> Bool {
        return true // Placeholder
    }

    func isOptimizedChargingEnabled() -> Bool {
        return true // Placeholder
    }

    func isCleanEnergyChargingEnabled() -> Bool {
        return false // Placeholder
    }

    func lastChargeToFullDate() -> String {
        return "Yesterday" // Placeholder
    }

    func batteryLevelColor() -> Color {
        switch batteryLevel {
        case 80...100:
            return .green
        case 40..<80:
            return .yellow
        default:
            return .red
        }
    }

    func toggleLogging() {
        enableLogging.toggle()
        let message = enableLogging ? "Logging enabled." : "Logging disabled."
        logInfo(message)
    }

    func startBatteryLevelUpdates() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let level = UIDevice.current.batteryLevel
            self.batteryLevel = level >= 0 ? Int(level * 100) : 0
            logInfo("Battery level updated to \(batteryLevel)%")
        }
    }

    private func logBatteryStatus() {
        guard enableLogging else { return }
        logInfo("BatteryInfoView appeared. Battery Level: \(batteryLevel)%")
    }

    private func loadLogs() {
        if let data = logsEncoded.data(using: .utf8),
           let decodedLogs = try? JSONDecoder().decode([String].self, from: data) {
            logs = decodedLogs
        }
    }

    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            logsEncoded = String(data: data, encoding: .utf8) ?? "[]"
        }
    }

    // MARK: - Logging Functions
    private func logInfo(_ message: String) {
        if enableLogging {
            logger.info("\(message)")
            logs.append("[INFO] \(message)")
            saveLogs()
        }
    }

    private func logWarning(_ message: String) {
        if enableLogging {
            logger.warning("\(message)")
            logs.append("[WARNING] \(message)")
            saveLogs()
        }
    }

    private func logError(_ message: String) {
        if enableLogging {
            logger.error("\(message)")
            logs.append("[ERROR] \(message)")
            saveLogs()
        }
    }
}
