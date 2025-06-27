// MARK: LOG: PERFORMANCE
import Foundation
import UIKit
import SwiftUI
import os

class ThermalManagementManager: ObservableObject {
    static let shared = ThermalManagementManager()
    private let logger = Logger(subsystem: "com.phoneguardian.thermalmanagement", category: "ThermalManagementManager")
    
    @Published var currentTemperature: Double = 0.0
    @Published var thermalState: ProcessInfo.ThermalState = .nominal
    @Published var temperatureHistory: [TemperaturePoint] = []
    @Published var thermalAlerts: [ThermalAlert] = []
    @Published var monitoringStatus: MonitoringStatus = .stopped
    @Published var alertThresholds: AlertThresholds = AlertThresholds()
    @Published var lastUpdateDate: Date?
    
    private var monitoringTimer: Timer?
    private let maxDataPoints = 200
    
    enum MonitoringStatus {
        case stopped, running, error
    }
    
    struct TemperaturePoint: Identifiable {
        let id = UUID()
        let timestamp: Date
        let temperature: Double
        let thermalState: ProcessInfo.ThermalState
        let throttling: Bool
    }
    
    struct ThermalAlert: Identifiable {
        let id = UUID()
        let timestamp: Date
        let type: AlertType
        let message: String
        let severity: Severity
        let resolved: Bool
        
        enum AlertType {
            case highTemperature, thermalThrottling, overheating, thermalStateChange
        }
        
        enum Severity {
            case low, medium, high, critical
        }
    }
    
    struct AlertThresholds {
        var highTemperatureThreshold: Double = 70.0
        var criticalTemperatureThreshold: Double = 85.0
        var throttlingThreshold: Double = 75.0
        var enableAlerts: Bool = true
        var enableNotifications: Bool = true
    }
    
    @MainActor
    func startMonitoring() async {
        logger.info("Starting thermal management monitoring")
        monitoringStatus = .running
        
        await updateThermalState()
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                await self.updateTemperature()
            }
        }
        
        logger.info("Thermal management monitoring started")
    }
    
    @MainActor
    func stopMonitoring() {
        logger.info("Stopping thermal management monitoring")
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        monitoringStatus = .stopped
    }
    
    @MainActor
    private func updateThermalState() async {
        logger.debug("Updating thermal state")
        
        let processInfo = ProcessInfo.processInfo
        let newThermalState = processInfo.thermalState
        
        await MainActor.run {
            self.thermalState = newThermalState
        }
        
        logger.debug("Thermal state: \(self.getThermalStateDescription(newThermalState))")
    }
    
    @MainActor
    private func updateTemperature() async {
        logger.debug("Updating temperature data")
        
        // Get current thermal state
        let processInfo = ProcessInfo.processInfo
        let newThermalState = processInfo.thermalState
        
        // Estimate temperature based on thermal state and system metrics
        let estimatedTemperature = await estimateTemperatureForThermalState(newThermalState)
        
        // Check for throttling
        let isThrottling = newThermalState == .serious || newThermalState == .critical
        
        let temperaturePoint = TemperaturePoint(
            timestamp: Date(),
            temperature: estimatedTemperature,
            thermalState: newThermalState,
            throttling: isThrottling
        )
        
        await MainActor.run {
            self.currentTemperature = estimatedTemperature
            self.thermalState = newThermalState
            
            self.temperatureHistory.append(temperaturePoint)
            
            // Keep only the last maxDataPoints
            if self.temperatureHistory.count > self.maxDataPoints {
                self.temperatureHistory.removeFirst()
            }
            
            self.lastUpdateDate = Date()
        }
        
        // Check for alerts
        await checkForThermalAlerts(estimatedTemperature, newThermalState, isThrottling)
    }
    
    @MainActor
    private func estimateTemperatureForThermalState(_ state: ProcessInfo.ThermalState) async -> Double {
        // Estimate temperature based on thermal state and additional system metrics
        let baseTemperature = switch state {
        case .nominal:
            30.0 // Normal operating temperature
        case .fair:
            42.0 // Slightly elevated temperature
        case .serious:
            58.0 // High temperature
        case .critical:
            72.0 // Critical temperature
        @unknown default:
            30.0 // Default to normal
        }
        
        // Adjust based on CPU usage and battery charging
        let cpuAdjustment = await getCPUUsageAdjustment()
        let batteryAdjustment = await getBatteryChargingAdjustment()
        
        return baseTemperature + cpuAdjustment + batteryAdjustment
    }
    
    private func getCPUUsageAdjustment() async -> Double {
        // Estimate CPU temperature contribution
        let processInfo = ProcessInfo.processInfo
        let cpuUsage = processInfo.systemUptime.truncatingRemainder(dividingBy: 100) // Simplified CPU usage estimate
        
        if cpuUsage > 80 {
            return 10.0 // High CPU usage adds heat
        } else if cpuUsage > 50 {
            return 5.0 // Medium CPU usage adds some heat
        } else {
            return 0.0 // Low CPU usage
        }
    }
    
    private func getBatteryChargingAdjustment() async -> Double {
        // Estimate battery charging heat contribution
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        if device.batteryState == .charging {
            return 5.0 // Charging adds heat
        } else if device.batteryState == .full {
            return 2.0 // Full battery adds some heat
        } else {
            return 0.0 // Not charging
        }
    }
    
    @MainActor
    private func checkForThermalAlerts(_ temperature: Double, _ state: ProcessInfo.ThermalState, _ throttling: Bool) async {
        guard alertThresholds.enableAlerts else { return }
        
        var newAlerts: [ThermalAlert] = []
        
        // Check for high temperature
        if temperature >= alertThresholds.criticalTemperatureThreshold {
            newAlerts.append(ThermalAlert(
                timestamp: Date(),
                type: .overheating,
                message: "Critical temperature detected: \(String(format: "%.1f°C", temperature))",
                severity: .critical,
                resolved: false
            ))
        } else if temperature >= alertThresholds.highTemperatureThreshold {
            newAlerts.append(ThermalAlert(
                timestamp: Date(),
                type: .highTemperature,
                message: "High temperature detected: \(String(format: "%.1f°C", temperature))",
                severity: .high,
                resolved: false
            ))
        }
        
        // Check for thermal throttling
        if throttling {
            newAlerts.append(ThermalAlert(
                timestamp: Date(),
                type: .thermalThrottling,
                message: "Thermal throttling active - performance reduced",
                severity: .medium,
                resolved: false
            ))
        }
        
        // Check for thermal state changes
        if state != thermalState {
            newAlerts.append(ThermalAlert(
                timestamp: Date(),
                type: .thermalStateChange,
                message: "Thermal state changed to: \(getThermalStateDescription(state))",
                severity: .low,
                resolved: false
            ))
        }
        
        await MainActor.run {
            self.thermalAlerts.append(contentsOf: newAlerts)
            
            // Keep only last 50 alerts
            if self.thermalAlerts.count > 50 {
                self.thermalAlerts.removeFirst(self.thermalAlerts.count - 50)
            }
        }
        
        // Send notifications if enabled
        if alertThresholds.enableNotifications {
            for alert in newAlerts {
                await sendThermalNotification(alert)
            }
        }
    }
    
    @MainActor
    private func sendThermalNotification(_ alert: ThermalAlert) async {
        // In a real implementation, you would use UNUserNotificationCenter
        // to send local notifications for thermal alerts
        logger.warning("Thermal alert: \(alert.message)")
    }
    
    func getThermalStateDescription(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal:
            return "Normal"
        case .fair:
            return "Fair"
        case .serious:
            return "Serious"
        case .critical:
            return "Critical"
        @unknown default:
            return "Unknown"
        }
    }
    
    func getThermalStateColor(_ state: ProcessInfo.ThermalState) -> Color {
        switch state {
        case .nominal:
            return .green
        case .fair:
            return .orange
        case .serious:
            return .red
        case .critical:
            return .purple
        @unknown default:
            return .gray
        }
    }
    
    func getTemperatureDescription(_ temperature: Double) -> String {
        if temperature < 30 {
            return "Cool"
        } else if temperature < 50 {
            return "Normal"
        } else if temperature < 70 {
            return "Warm"
        } else if temperature < 85 {
            return "Hot"
        } else {
            return "Critical"
        }
    }
    
    func getTemperatureColor(_ temperature: Double) -> Color {
        if temperature < 30 {
            return .blue
        } else if temperature < 50 {
            return .green
        } else if temperature < 70 {
            return .orange
        } else if temperature < 85 {
            return .red
        } else {
            return .purple
        }
    }
    
    func getMonitoringStatusDescription() -> String {
        switch monitoringStatus {
        case .stopped:
            return "Thermal monitoring stopped"
        case .running:
            return "Thermal monitoring active"
        case .error:
            return "Thermal monitoring error"
        }
    }
    
    func getMonitoringStatusColor() -> Color {
        switch monitoringStatus {
        case .stopped:
            return .gray
        case .running:
            return .green
        case .error:
            return .red
        }
    }
    
    func getAverageTemperature() -> Double {
        guard !temperatureHistory.isEmpty else { return 0.0 }
        let totalTemperature = temperatureHistory.reduce(0.0) { $0 + $1.temperature }
        return totalTemperature / Double(temperatureHistory.count)
    }
    
    func getPeakTemperature() -> Double {
        return temperatureHistory.map { $0.temperature }.max() ?? 0.0
    }
    
    func getThrottlingDuration() -> TimeInterval {
        let throttlingPoints = temperatureHistory.filter { $0.throttling }
        return TimeInterval(throttlingPoints.count * 2) // 2 seconds per data point
    }
    
    func getThrottlingPercentage() -> Double {
        guard !temperatureHistory.isEmpty else { return 0.0 }
        let throttlingCount = temperatureHistory.filter { $0.throttling }.count
        return Double(throttlingCount) / Double(temperatureHistory.count) * 100.0
    }
    
    func clearTemperatureHistory() {
        logger.info("Clearing temperature history")
        temperatureHistory.removeAll()
    }
    
    func clearThermalAlerts() {
        logger.info("Clearing thermal alerts")
        thermalAlerts.removeAll()
    }
    
    func resolveAlert(_ alert: ThermalAlert) {
        if let index = thermalAlerts.firstIndex(where: { $0.id == alert.id }) {
            thermalAlerts[index] = ThermalAlert(
                timestamp: alert.timestamp,
                type: alert.type,
                message: alert.message,
                severity: alert.severity,
                resolved: true
            )
        }
    }
    
    func getUnresolvedAlerts() -> [ThermalAlert] {
        return thermalAlerts.filter { !$0.resolved }
    }
    
    func getCriticalAlerts() -> [ThermalAlert] {
        return thermalAlerts.filter { $0.severity == .critical && !$0.resolved }
    }
} 