// MARK: LOG: PERFORMANCE
import Foundation
import UIKit
import SwiftUI
import os

@MainActor
class GPUMonitoringManager: ObservableObject {
    static let shared = GPUMonitoringManager()
    private let logger = Logger(subsystem: "com.phoneguardian.gpumonitoring", category: "GPUMonitoringManager")
    
    @Published var gpuUsage: Double = 0.0
    @Published var gpuLoad: Double = 0.0
    @Published var gpuTemperature: Double = 0.0
    @Published var gpuActivity: [GPUActivityPoint] = []
    @Published var gpuInfo: GPUInfo = GPUInfo()
    @Published var monitoringStatus: MonitoringStatus = .stopped
    @Published var lastUpdateDate: Date?
    
    private var monitoringTimer: Timer?
    private let maxDataPoints = 100
    
    enum MonitoringStatus {
        case stopped, running, error
    }
    
    struct GPUActivityPoint: Identifiable {
        let id = UUID()
        let timestamp: Date
        let usage: Double
        let load: Double
        let temperature: Double
    }
    
    struct GPUInfo {
        var name: String = ""
        var cores: Int = 0
        var memory: String = ""
        var architecture: String = ""
        var maxFrequency: Double = 0.0
        var currentFrequency: Double = 0.0
    }
    
    func startMonitoring() async {
        logger.info("Starting GPU monitoring")
        monitoringStatus = .running
        
        await updateGPUInfo()
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateGPUStats()
            }
        }
        
        logger.info("GPU monitoring started")
    }
    
    func stopMonitoring() {
        logger.info("Stopping GPU monitoring")
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        monitoringStatus = .stopped
    }
    
    private func updateGPUInfo() async {
        logger.debug("Updating GPU information")
        
        // Get device-specific GPU information
        let deviceModel = DeviceCapabilities.getDeviceModelCode()
        let gpuInfo = await getGPUInfoForDevice(deviceModel)
        
        self.gpuInfo = gpuInfo
    }
    
    private func updateGPUStats() async {
        logger.debug("Updating GPU statistics")
        
        // In a real implementation, you would use Metal Performance Shaders or private APIs
        // to get actual GPU usage data. For now, we'll simulate the data.
        
        let simulatedUsage = Double.random(in: 0.0...100.0)
        let simulatedLoad = Double.random(in: 0.0...100.0)
        let simulatedTemperature = Double.random(in: 30.0...80.0)
        
        let activityPoint = GPUActivityPoint(
            timestamp: Date(),
            usage: simulatedUsage,
            load: simulatedLoad,
            temperature: simulatedTemperature
        )
        
        self.gpuUsage = simulatedUsage
        self.gpuLoad = simulatedLoad
        self.gpuTemperature = simulatedTemperature
        
        self.gpuActivity.append(activityPoint)
        
        // Keep only the last maxDataPoints
        if self.gpuActivity.count > self.maxDataPoints {
            self.gpuActivity.removeFirst()
        }
        
        self.lastUpdateDate = Date()
    }
    
    private func getGPUInfoForDevice(_ deviceModel: String) async -> GPUInfo {
        // Map device models to GPU information
        switch deviceModel {
        case "iPhone15,1", "iPhone15,2": // iPhone 15 Pro
            return GPUInfo(
                name: "Apple A17 Pro GPU",
                cores: 6,
                memory: "6GB",
                architecture: "Metal 3",
                maxFrequency: 1.8,
                currentFrequency: 1.2
            )
        case "iPhone15,3", "iPhone15,4": // iPhone 15 Pro Max
            return GPUInfo(
                name: "Apple A17 Pro GPU",
                cores: 6,
                memory: "8GB",
                architecture: "Metal 3",
                maxFrequency: 1.8,
                currentFrequency: 1.2
            )
        case "iPhone14,2", "iPhone14,3": // iPhone 14 Pro
            return GPUInfo(
                name: "Apple A16 Bionic GPU",
                cores: 5,
                memory: "6GB",
                architecture: "Metal 3",
                maxFrequency: 1.6,
                currentFrequency: 1.0
            )
        case "iPhone14,4", "iPhone14,5": // iPhone 14
            return GPUInfo(
                name: "Apple A15 Bionic GPU",
                cores: 5,
                memory: "6GB",
                architecture: "Metal 3",
                maxFrequency: 1.5,
                currentFrequency: 0.9
            )
        case "iPad13,1", "iPad13,2": // iPad Air (5th generation)
            return GPUInfo(
                name: "Apple M1 GPU",
                cores: 8,
                memory: "8GB",
                architecture: "Metal 3",
                maxFrequency: 1.2,
                currentFrequency: 0.8
            )
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": // iPad Pro (5th generation)
            return GPUInfo(
                name: "Apple M1 GPU",
                cores: 8,
                memory: "8GB/16GB",
                architecture: "Metal 3",
                maxFrequency: 1.2,
                currentFrequency: 0.8
            )
        default:
            return GPUInfo(
                name: "Unknown GPU",
                cores: 0,
                memory: "Unknown",
                architecture: "Unknown",
                maxFrequency: 0.0,
                currentFrequency: 0.0
            )
        }
    }
    
    func getGPUUsageDescription() -> String {
        if gpuUsage < 20 {
            return "Low"
        } else if gpuUsage < 50 {
            return "Moderate"
        } else if gpuUsage < 80 {
            return "High"
        } else {
            return "Very High"
        }
    }
    
    func getGPULoadDescription() -> String {
        if gpuLoad < 20 {
            return "Idle"
        } else if gpuLoad < 50 {
            return "Light"
        } else if gpuLoad < 80 {
            return "Moderate"
        } else {
            return "Heavy"
        }
    }
    
    func getGPUTemperatureDescription() -> String {
        if gpuTemperature < 40 {
            return "Cool"
        } else if gpuTemperature < 60 {
            return "Normal"
        } else if gpuTemperature < 75 {
            return "Warm"
        } else {
            return "Hot"
        }
    }
    
    func getGPUUsageColor() -> Color {
        if gpuUsage < 30 {
            return .green
        } else if gpuUsage < 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    func getGPULoadColor() -> Color {
        if gpuLoad < 30 {
            return .green
        } else if gpuLoad < 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    func getGPUTemperatureColor() -> Color {
        if gpuTemperature < 40 {
            return .green
        } else if gpuTemperature < 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    func formatFrequency(_ frequency: Double) -> String {
        return String(format: "%.1f GHz", frequency)
    }
    
    func getMonitoringStatusDescription() -> String {
        switch monitoringStatus {
        case .stopped:
            return "GPU monitoring stopped"
        case .running:
            return "GPU monitoring active"
        case .error:
            return "GPU monitoring error"
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
    
    func getAverageGPUUsage() -> Double {
        guard !gpuActivity.isEmpty else { return 0.0 }
        let totalUsage = gpuActivity.reduce(0.0) { $0 + $1.usage }
        return totalUsage / Double(gpuActivity.count)
    }
    
    func getPeakGPUUsage() -> Double {
        return gpuActivity.map { $0.usage }.max() ?? 0.0
    }
    
    func getAverageGPUTemperature() -> Double {
        guard !gpuActivity.isEmpty else { return 0.0 }
        let totalTemperature = gpuActivity.reduce(0.0) { $0 + $1.temperature }
        return totalTemperature / Double(gpuActivity.count)
    }
    
    func getPeakGPUTemperature() -> Double {
        return gpuActivity.map { $0.temperature }.max() ?? 0.0
    }
    
    func clearActivityData() {
        logger.info("Clearing GPU activity data")
        gpuActivity.removeAll()
    }
} 