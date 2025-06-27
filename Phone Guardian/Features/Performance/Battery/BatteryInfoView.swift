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
    @State private var batteryHealth: String = getBatteryHealthStatus()

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
        // Check if device supports fast charging based on model
        let modelCode = DeviceCapabilities.getDeviceModelCode()
        // iPhone 8 and later support fast charging
        return modelCode.contains("iPhone") && 
               (modelCode.contains("iPhone8") || 
                modelCode.contains("iPhone9") || 
                modelCode.contains("iPhone10") || 
                modelCode.contains("iPhone11") || 
                modelCode.contains("iPhone12") || 
                modelCode.contains("iPhone13") || 
                modelCode.contains("iPhone14") || 
                modelCode.contains("iPhone15") || 
                modelCode.contains("iPhone16"))
    }

    func supportsWirelessCharging() -> Bool {
        // Check if device supports wireless charging based on model
        let modelCode = DeviceCapabilities.getDeviceModelCode()
        // iPhone 8 and later support wireless charging
        return modelCode.contains("iPhone") && 
               (modelCode.contains("iPhone8") || 
                modelCode.contains("iPhone9") || 
                modelCode.contains("iPhone10") || 
                modelCode.contains("iPhone11") || 
                modelCode.contains("iPhone12") || 
                modelCode.contains("iPhone13") || 
                modelCode.contains("iPhone14") || 
                modelCode.contains("iPhone15") || 
                modelCode.contains("iPhone16"))
    }

    func isOptimizedChargingEnabled() -> Bool {
        // Check if optimized charging is enabled
        // This would require checking system settings
        return UserDefaults.standard.bool(forKey: "OptimizedChargingEnabled")
    }

    func isCleanEnergyChargingEnabled() -> Bool {
        // Check if clean energy charging is enabled
        // This would require checking system settings
        return UserDefaults.standard.bool(forKey: "CleanEnergyChargingEnabled")
    }

    func lastChargeToFullDate() -> String {
        // Get the last charge to full date from UserDefaults
        if let lastChargeDate = UserDefaults.standard.object(forKey: "LastChargeToFullDate") as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: lastChargeDate)
        }
        return "Unknown"
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

    static func getBatteryHealthStatus() -> String {
        // Get battery health based on current level and device age
        let batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel >= 0.8 {
            return "Good"
        } else if batteryLevel >= 0.6 {
            return "Fair"
        } else {
            return "Poor"
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
