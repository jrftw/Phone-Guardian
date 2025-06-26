import SwiftUI
import os
import SystemConfiguration
import AVFoundation
import CoreTelephony
import UIKit
import Network
import CoreMotion

// MARK: - Health Issue Model
struct HealthIssue: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let severity: HealthIssueSeverity
    let category: HealthIssueCategory
}

enum HealthIssueSeverity {
    case critical
    case warning
    case info
}

enum HealthIssueCategory {
    case storage
    case battery
    case memory
    case network
    case sensors
    case camera
    case microphone
    case speakers
    case thermal
}

struct HealthCheckView: View {
    @State private var healthIssues: [HealthIssue] = []
    @State private var isChecking = false
    @State private var lastCheckDate: Date?
    private let logger = Logger(subsystem: "com.phoneguardian.health", category: "HealthCheckView")
    private let motionManager = CMMotionManager()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Status Overview Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Device Health Status", icon: "heart.fill")
                    
                    LazyVStack(spacing: 8) {
                        if healthIssues.isEmpty {
                            ModernInfoRow(icon: "checkmark.circle.fill", label: "Status", value: "Healthy", iconColor: .green)
                        } else {
                            ModernInfoRow(icon: "exclamationmark.triangle.fill", label: "Status", value: "\(healthIssues.count) Issues Found", iconColor: .orange)
                        }
                        
                        if let lastCheck = lastCheckDate {
                            ModernInfoRow(icon: "clock", label: "Last Check", value: lastCheck.formatted(), iconColor: .blue)
                        }
                    }
                }
                .modernCard()
                
                // Run Health Check Button Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Health Check", icon: "stethoscope")
                    
                    Button(action: runHealthCheck) {
                        HStack {
                            if isChecking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Image(systemName: isChecking ? "hourglass" : "play.circle.fill")
                            Text(isChecking ? "Checking..." : "Run Health Check")
                        }
                    }
                    .modernButton(backgroundColor: .blue)
                    .disabled(isChecking)
                }
                .modernCard()
                
                // Issues List Section
                if !healthIssues.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        ModernSectionHeader(title: "Detected Issues", icon: "exclamationmark.triangle.fill")
                        
                        LazyVStack(spacing: 12) {
                            ForEach(healthIssues) { issue in
                                ModernHealthIssueRow(issue: issue)
                            }
                        }
                    }
                    .modernCard()
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logger.info("HealthCheckView appeared")
        }
    }
    
    private func runHealthCheck() {
        isChecking = true
        healthIssues.removeAll()
        
        // Run checks in parallel
        Task {
            await checkStorage()
            await checkBattery()
            await checkMemory()
            await checkNetwork()
            await checkSensors()
            await checkCamera()
            await checkMicrophone()
            await checkSpeakers()
            
            DispatchQueue.main.async {
                isChecking = false
                lastCheckDate = Date()
                logger.info("Health check completed with \(healthIssues.count) issues found")
            }
        }
    }
    
    // MARK: - Health Check Functions
    
    private func checkStorage() async {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let freeSpace = attributes[.systemFreeSize] as? NSNumber {
                let freeSpaceGB = freeSpace.doubleValue / 1_000_000_000
                if freeSpaceGB < 1 {
                    healthIssues.append(HealthIssue(
                        title: "Low Storage",
                        description: "Less than 1GB of free space",
                        severity: .warning,
                        category: .storage
                    ))
                }
            }
        } catch {
            logger.error("Failed to check storage: \(error.localizedDescription)")
        }
    }
    
    private func checkBattery() async {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        if device.batteryLevel < 0.2 {
            healthIssues.append(HealthIssue(
                title: "Low Battery",
                description: "Battery level below 20%",
                severity: .warning,
                category: .battery
            ))
        }
        
        if device.batteryState == .charging {
            // Check if device is getting too hot while charging
            let thermalState = ProcessInfo.processInfo.thermalState
            if thermalState == .critical || thermalState == .serious {
                healthIssues.append(HealthIssue(
                    title: "High Temperature",
                    description: "Device is getting hot while charging",
                    severity: .critical,
                    category: .thermal
                ))
            }
        }
    }
    
    private func checkMemory() async {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemory = Double(info.resident_size) / 1024.0 / 1024.0 / 1024.0 // Convert to GB
            if usedMemory > 3.0 { // More than 3GB used
                healthIssues.append(HealthIssue(
                    title: "High Memory Usage",
                    description: "Device is using more than 3GB of RAM",
                    severity: .warning,
                    category: .memory
                ))
            }
        }
    }
    
    private func checkNetwork() async {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { (path: NWPath) in
            if path.status != .satisfied {
                healthIssues.append(HealthIssue(
                    title: "No Network Connection",
                    description: "Device is not connected to any network",
                    severity: .warning,
                    category: .network
                ))
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
    private func checkSensors() async {
        // Check if motion sensors are available
        if !motionManager.isAccelerometerAvailable {
            healthIssues.append(HealthIssue(
                title: "Accelerometer Unavailable",
                description: "Motion sensor is not working properly",
                severity: .warning,
                category: .sensors
            ))
        }
    }
    
    private func checkCamera() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied || status == .restricted {
            healthIssues.append(HealthIssue(
                title: "Camera Access Denied",
                description: "Camera permissions are not granted",
                severity: .warning,
                category: .camera
            ))
        }
    }
    
    private func checkMicrophone() async {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .denied || status == .restricted {
            healthIssues.append(HealthIssue(
                title: "Microphone Access Denied",
                description: "Microphone permissions are not granted",
                severity: .warning,
                category: .microphone
            ))
        }
    }
    
    private func checkSpeakers() async {
        // Basic speaker check - in a real app, you might play a test tone
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            healthIssues.append(HealthIssue(
                title: "Audio System Issue",
                description: "Speaker or audio system may not be working properly",
                severity: .warning,
                category: .speakers
            ))
        }
    }
}

// MARK: - Modern Health Issue Row
struct ModernHealthIssueRow: View {
    let issue: HealthIssue
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: severityIcon)
                .font(.title2)
                .foregroundColor(severityColor)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(issue.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(issue.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(severityColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var severityIcon: String {
        switch issue.severity {
        case .critical:
            return "exclamationmark.triangle.fill"
        case .warning:
            return "exclamationmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
    
    private var severityColor: Color {
        switch issue.severity {
        case .critical:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }
} 
