// MARK: LOG: DEVICE
import Foundation
import UIKit
import SwiftUI
import os

class HardwareHealthManager: ObservableObject {
    static let shared = HardwareHealthManager()
    private let logger = Logger(subsystem: "com.phoneguardian.hardwarehealth", category: "HardwareHealthManager")
    
    @Published var batteryHealth: BatteryHealth = BatteryHealth()
    @Published var memoryHealth: MemoryHealth = MemoryHealth()
    @Published var storageHealth: StorageHealth = StorageHealth()
    @Published var componentHealth: ComponentHealth = ComponentHealth()
    @Published var lastUpdateDate: Date?
    
    struct BatteryHealth {
        var cycleCount: Int = 0
        var healthPercentage: Double = 0.0
        var maximumCapacity: Double = 0.0
        var designCapacity: Double = 0.0
        var isCharging: Bool = false
        var temperature: Double = 0.0
        var voltage: Double = 0.0
        var healthStatus: HealthStatus = .unknown
        
        enum HealthStatus {
            case excellent, good, fair, poor, critical, unknown
        }
    }
    
    struct MemoryHealth {
        var totalMemory: UInt64 = 0
        var availableMemory: UInt64 = 0
        var usedMemory: UInt64 = 0
        var memoryPressure: MemoryPressure = .normal
        var degradationLevel: Double = 0.0
        var healthStatus: HealthStatus = .unknown
        
        enum MemoryPressure {
            case normal, warning, critical
        }
        
        enum HealthStatus {
            case excellent, good, fair, poor, critical, unknown
        }
    }
    
    struct StorageHealth {
        var totalSpace: UInt64 = 0
        var availableSpace: UInt64 = 0
        var usedSpace: UInt64 = 0
        var wearLevel: Double = 0.0
        var healthStatus: HealthStatus = .unknown
        var ssdType: String = "Unknown"
        
        enum HealthStatus {
            case excellent, good, fair, poor, critical, unknown
        }
    }
    
    struct ComponentHealth {
        var cpuHealth: Double = 0.0
        var gpuHealth: Double = 0.0
        var sensorHealth: [String: Double] = [:]
        var overallHealth: Double = 0.0
        var estimatedLifespan: TimeInterval = 0
        var healthStatus: HealthStatus = .unknown
        
        enum HealthStatus {
            case excellent, good, fair, poor, critical, unknown
        }
    }
    
    func updateHardwareHealth() async {
        logger.info("Starting hardware health update")
        
        await Task.detached(priority: .userInitiated) {
            await self.updateBatteryHealth()
            await self.updateMemoryHealth()
            await self.updateStorageHealth()
            await self.updateComponentHealth()
        }.value
        
        await MainActor.run {
            self.lastUpdateDate = Date()
        }
        logger.info("Hardware health update completed")
    }
    
    private func updateBatteryHealth() async {
        logger.debug("Updating battery health information")
        
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        // Get battery state
        let batteryState = device.batteryState
        
        // Simulate battery health data (in real implementation, you'd need private APIs or device-specific methods)
        let simulatedCycleCount = Int.random(in: 100...800)
        let simulatedHealthPercentage = Double.random(in: 70.0...100.0)
        let simulatedMaxCapacity = 100.0
        let simulatedDesignCapacity = 100.0
        
        await MainActor.run {
            self.batteryHealth.cycleCount = simulatedCycleCount
            self.batteryHealth.healthPercentage = simulatedHealthPercentage
            self.batteryHealth.maximumCapacity = simulatedMaxCapacity
            self.batteryHealth.designCapacity = simulatedDesignCapacity
            self.batteryHealth.isCharging = batteryState == .charging || batteryState == .full
            self.batteryHealth.temperature = Double.random(in: 20.0...35.0)
            self.batteryHealth.voltage = Double.random(in: 3.7...4.2)
            self.batteryHealth.healthStatus = self.calculateBatteryHealthStatus(simulatedHealthPercentage)
        }
    }
    
    private func updateMemoryHealth() async {
        logger.debug("Updating memory health information")
        
        let processInfo = ProcessInfo.processInfo
        let totalMemory = processInfo.physicalMemory
        let availableMemory = UInt64(os_proc_available_memory())
        let usedMemory = totalMemory - availableMemory
        let memoryUsagePercentage = (totalMemory > 0) ? Double(usedMemory) / Double(totalMemory) * 100.0 : 0.0
        
        // Calculate memory pressure
        let memoryPressure: MemoryHealth.MemoryPressure
        if memoryUsagePercentage > 90 {
            memoryPressure = .critical
        } else if memoryUsagePercentage > 80 {
            memoryPressure = .warning
        } else {
            memoryPressure = .normal
        }
        
        // Simulate memory degradation (in real implementation, you'd need more sophisticated monitoring)
        let degradationLevel = Double.random(in: 0.0...10.0)
        
        await MainActor.run {
            self.memoryHealth.totalMemory = totalMemory
            self.memoryHealth.availableMemory = availableMemory
            self.memoryHealth.usedMemory = usedMemory
            self.memoryHealth.memoryPressure = memoryPressure
            self.memoryHealth.degradationLevel = degradationLevel
            self.memoryHealth.healthStatus = self.calculateMemoryHealthStatus(memoryUsagePercentage, degradationLevel)
        }
    }
    
    private func updateStorageHealth() async {
        logger.debug("Updating storage health information")
        
        let fileManager = FileManager.default
        guard let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()) else {
            logger.error("Failed to get file system attributes")
            return
        }
        
        let totalSpace = attributes[.systemSize] as? UInt64 ?? 0
        let freeSpace = attributes[.systemFreeSize] as? UInt64 ?? 0
        let usedSpace = totalSpace - freeSpace
        let usagePercentage = (totalSpace > 0) ? Double(usedSpace) / Double(totalSpace) * 100.0 : 0.0
        
        // Simulate storage wear level (in real implementation, you'd need device-specific APIs)
        let wearLevel = Double.random(in: 0.0...20.0)
        
        await MainActor.run {
            self.storageHealth.totalSpace = totalSpace
            self.storageHealth.availableSpace = freeSpace
            self.storageHealth.usedSpace = usedSpace
            self.storageHealth.wearLevel = wearLevel
            self.storageHealth.ssdType = self.detectSSDType()
            self.storageHealth.healthStatus = self.calculateStorageHealthStatus(usagePercentage, wearLevel)
        }
    }
    
    private func updateComponentHealth() async {
        logger.debug("Updating component health information")
        
        // Simulate component health data (in real implementation, you'd need device-specific APIs)
        let cpuHealth = Double.random(in: 85.0...100.0)
        let gpuHealth = Double.random(in: 85.0...100.0)
        let sensorHealth = [
            "Accelerometer": Double.random(in: 90.0...100.0),
            "Gyroscope": Double.random(in: 90.0...100.0),
            "Magnetometer": Double.random(in: 90.0...100.0),
            "Barometer": Double.random(in: 90.0...100.0)
        ]
        
        let overallHealth = (cpuHealth + gpuHealth + sensorHealth.values.reduce(0, +)) / Double(sensorHealth.count + 2)
        let estimatedLifespan = TimeInterval.random(in: 2 * 365 * 24 * 3600...5 * 365 * 24 * 3600) // 2-5 years
        
        await MainActor.run {
            self.componentHealth.cpuHealth = cpuHealth
            self.componentHealth.gpuHealth = gpuHealth
            self.componentHealth.sensorHealth = sensorHealth
            self.componentHealth.overallHealth = overallHealth
            self.componentHealth.estimatedLifespan = estimatedLifespan
            self.componentHealth.healthStatus = self.calculateComponentHealthStatus(overallHealth)
        }
    }
    
    private func calculateBatteryHealthStatus(_ healthPercentage: Double) -> BatteryHealth.HealthStatus {
        switch healthPercentage {
        case 90...100:
            return .excellent
        case 80..<90:
            return .good
        case 70..<80:
            return .fair
        case 60..<70:
            return .poor
        case 0..<60:
            return .critical
        default:
            return .unknown
        }
    }
    
    private func calculateMemoryHealthStatus(_ usagePercentage: Double, _ degradationLevel: Double) -> MemoryHealth.HealthStatus {
        let combinedScore = (100 - usagePercentage) - degradationLevel
        switch combinedScore {
        case 80...100:
            return .excellent
        case 60..<80:
            return .good
        case 40..<60:
            return .fair
        case 20..<40:
            return .poor
        case 0..<20:
            return .critical
        default:
            return .unknown
        }
    }
    
    private func calculateStorageHealthStatus(_ usagePercentage: Double, _ wearLevel: Double) -> StorageHealth.HealthStatus {
        let combinedScore = (100 - usagePercentage) - wearLevel
        switch combinedScore {
        case 80...100:
            return .excellent
        case 60..<80:
            return .good
        case 40..<60:
            return .fair
        case 20..<40:
            return .poor
        case 0..<20:
            return .critical
        default:
            return .unknown
        }
    }
    
    private func calculateComponentHealthStatus(_ overallHealth: Double) -> ComponentHealth.HealthStatus {
        switch overallHealth {
        case 90...100:
            return .excellent
        case 80..<90:
            return .good
        case 70..<80:
            return .fair
        case 60..<70:
            return .poor
        case 0..<60:
            return .critical
        default:
            return .unknown
        }
    }
    
    private func detectSSDType() -> String {
        // In a real implementation, you'd detect the actual SSD type
        // For now, return a simulated value
        return "NVMe SSD"
    }
    
    func getBatteryHealthStatusColor(_ status: BatteryHealth.HealthStatus) -> Color {
        switch status {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        case .critical: return .purple
        case .unknown: return .gray
        }
    }
    
    func getMemoryHealthStatusColor(_ status: MemoryHealth.HealthStatus) -> Color {
        switch status {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        case .critical: return .purple
        case .unknown: return .gray
        }
    }
    
    func getStorageHealthStatusColor(_ status: StorageHealth.HealthStatus) -> Color {
        switch status {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        case .critical: return .purple
        case .unknown: return .gray
        }
    }
    
    func getComponentHealthStatusColor(_ status: ComponentHealth.HealthStatus) -> Color {
        switch status {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        case .critical: return .purple
        case .unknown: return .gray
        }
    }
    
    func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let years = Int(timeInterval) / (365 * 24 * 3600)
        let months = Int(timeInterval) % (365 * 24 * 3600) / (30 * 24 * 3600)
        return "\(years)y \(months)m"
    }
} 