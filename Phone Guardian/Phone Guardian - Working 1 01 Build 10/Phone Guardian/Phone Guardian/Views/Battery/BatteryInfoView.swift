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
        VStack(alignment: .leading, spacing: 20) {
            Text("BATTERY")
                .font(.title2)
                .bold()

            Group {
                InfoRow(label: "Battery Level", value: "\(batteryLevel)%")
                    .foregroundColor(batteryLevelColor())
                InfoRow(label: "Battery State", value: getBatteryState())
                InfoRow(label: "Battery Health", value: batteryHealth)
                InfoRow(label: "Fast Charging Support", value: supportsFastCharging() ? "✔︎" : "✘")
                InfoRow(label: "Wireless Charging Support", value: supportsWirelessCharging() ? "✔︎" : "✘")
                InfoRow(label: "Charge Limit", value: "85%") // Placeholder
                InfoRow(label: "Low Power Mode", value: ProcessInfo.processInfo.isLowPowerModeEnabled ? "Enabled" : "Disabled")
                InfoRow(label: "Optimized Battery Charging", value: isOptimizedChargingEnabled() ? "Enabled" : "Disabled")
                InfoRow(label: "Clean Energy Charging", value: isCleanEnergyChargingEnabled() ? "Enabled" : "Disabled")
                InfoRow(label: "Last Charge to 100%", value: lastChargeToFullDate())
            }

            Divider()

            Button(action: toggleLogging) {
                Text(enableLogging ? "Disable Logging" : "Enable Logging")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(enableLogging ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            if enableLogging {
                Text("Logs Enabled: Monitoring...")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
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
