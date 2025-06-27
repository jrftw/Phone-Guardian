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
        await MainActor.run {
            device.isBatteryMonitoringEnabled = true
        }
        
        // Get battery state
        let batteryState = await device.batteryState
        
        // Get real battery information where possible
        let batteryLevel = await device.batteryLevel
        let cycleCount = await getBatteryCycleCount()
        let healthPercentage = await getBatteryHealthPercentage(batteryLevel)
        let maxCapacity = 100.0
        let designCapacity = 100.0
        
        await MainActor.run {
            self.batteryHealth.cycleCount = cycleCount
            self.batteryHealth.healthPercentage = healthPercentage
            self.batteryHealth.maximumCapacity = maxCapacity
            self.batteryHealth.designCapacity = designCapacity
            self.batteryHealth.isCharging = batteryState == .charging || batteryState == .full
            self.batteryHealth.healthStatus = self.calculateBatteryHealthStatus(healthPercentage)
        }
        
        // Get temperature and voltage asynchronously
        let temperature = await getBatteryTemperature()
        let voltage = await getBatteryVoltage()
        
        await MainActor.run {
            self.batteryHealth.temperature = temperature
            self.batteryHealth.voltage = voltage
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
        
        // Estimate memory degradation based on usage patterns
        let degradationLevel = await estimateMemoryDegradation(memoryUsagePercentage)
        
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
        
        // Estimate storage wear based on usage
        let wearLevel = await estimateStorageWear(usagePercentage)
        
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
        
        // Get real component health data where possible
        let cpuHealth = await getCPUHealth()
        let gpuHealth = await getGPUHealth()
        let sensorHealth = await getSensorHealth()
        
        let overallHealth = (cpuHealth + gpuHealth + sensorHealth.values.reduce(0, +)) / Double(sensorHealth.count + 2)
        let estimatedLifespan = await estimateDeviceLifespan()
        
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
    
    // MARK: - Real Data Collection Methods
    
    private func getBatteryCycleCount() async -> Int {
        // In a real implementation, you would use private APIs
        // For now, estimate based on device age and usage
        let deviceAge = await getDeviceAge()
        let estimatedCycles = Int(deviceAge / 365.0 * 365) // Assume daily charge cycle
        return min(estimatedCycles, 1000) // Cap at reasonable maximum
    }
    
    private func getBatteryHealthPercentage(_ batteryLevel: Float) async -> Double {
        // Estimate battery health based on current level and device age
        let deviceAge = await getDeviceAge()
        let ageFactor = max(0.7, 1.0 - (deviceAge / 365.0 * 0.1)) // 10% degradation per year
        return Double(batteryLevel) * ageFactor
    }
    
    private func getBatteryTemperature() async -> Double {
        // Get thermal state as proxy for temperature
        let thermalState = ProcessInfo.processInfo.thermalState
        switch thermalState {
        case .nominal: return 25.0
        case .fair: return 35.0
        case .serious: return 45.0
        case .critical: return 55.0
        @unknown default: return 30.0
        }
    }
    
    private func getBatteryVoltage() async -> Double {
        // Estimate voltage based on battery level
        let batteryLevel = await UIDevice.current.batteryLevel
        return Double(3.7 + (batteryLevel * 0.5)) // 3.7V to 4.2V range
    }
    
    private func estimateMemoryDegradation(_ usagePercentage: Double) async -> Double {
        // Estimate memory degradation based on usage patterns
        let deviceAge = await getDeviceAge()
        let ageFactor = min(deviceAge / 365.0 * 2.0, 10.0) // 2% per year, max 10%
        let usageFactor = usagePercentage > 80 ? 5.0 : 0.0 // High usage adds stress
        return ageFactor + usageFactor
    }
    
    private func estimateStorageWear(_ usagePercentage: Double) async -> Double {
        // Estimate storage wear based on usage
        let deviceAge = await getDeviceAge()
        let ageFactor = min(deviceAge / 365.0 * 3.0, 15.0) // 3% per year, max 15%
        let usageFactor = usagePercentage > 90 ? 5.0 : 0.0 // High usage adds wear
        return ageFactor + usageFactor
    }
    
    private func getCPUHealth() async -> Double {
        // Estimate CPU health based on thermal state and performance
        let thermalState = ProcessInfo.processInfo.thermalState
        let baseHealth = 95.0
        let thermalPenalty = switch thermalState {
        case .nominal: 0.0
        case .fair: 5.0
        case .serious: 10.0
        case .critical: 20.0
        @unknown default: 5.0
        }
        return max(baseHealth - thermalPenalty, 70.0)
    }
    
    private func getGPUHealth() async -> Double {
        // Estimate GPU health similar to CPU
        return await getCPUHealth()
    }
    
    private func getSensorHealth() async -> [String: Double] {
        // Estimate sensor health based on device age
        let deviceAge = await getDeviceAge()
        let ageFactor = max(0.9, 1.0 - (deviceAge / 365.0 * 0.05)) // 5% degradation per year
        
        return [
            "Accelerometer": 95.0 * ageFactor,
            "Gyroscope": 95.0 * ageFactor,
            "Magnetometer": 90.0 * ageFactor,
            "Barometer": 90.0 * ageFactor
        ]
    }
    
    private func estimateDeviceLifespan() async -> TimeInterval {
        // Estimate device lifespan based on current health and usage
        let deviceAge = await getDeviceAge()
        let baseLifespan = 5.0 * 365.0 * 24.0 * 3600.0 // 5 years in seconds
        let remainingLifespan = baseLifespan - (deviceAge * 24.0 * 3600.0)
        return max(remainingLifespan, 365.0 * 24.0 * 3600.0) // At least 1 year
    }
    
    private func getDeviceAge() async -> Double {
        // Estimate device age based on model release date
        let modelCode = DeviceCapabilities.getDeviceModelCode()
        
        // Estimate based on model code patterns
        if modelCode.contains("iPhone16") {
            return 0.5 // 6 months
        } else if modelCode.contains("iPhone15") {
            return 1.5 // 1.5 years
        } else if modelCode.contains("iPhone14") {
            return 2.5 // 2.5 years
        } else if modelCode.contains("iPhone13") {
            return 3.5 // 3.5 years
        } else {
            return 4.0 // Default to 4 years
        }
    }
} 