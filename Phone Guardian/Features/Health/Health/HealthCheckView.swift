import SwiftUI
import os
import SystemConfiguration
import AVFoundation
import CoreTelephony
import UIKit
import Network
import CoreMotion

struct HealthCheckView: View {
    @State private var healthIssues: [HealthIssue] = []
    @State private var isChecking = false
    @State private var lastCheckDate: Date?
    private let logger = Logger(subsystem: "com.phoneguardian.health", category: "HealthCheckView")
    private let motionManager = CMMotionManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status Overview
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Device Health Status", systemImage: "heart.fill")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        if healthIssues.isEmpty {
                            InfoRow(label: "Status", value: "Healthy")
                                .foregroundColor(.green)
                        } else {
                            InfoRow(label: "Status", value: "\(healthIssues.count) Issues Found")
                                .foregroundColor(.orange)
                        }
                        
                        if let lastCheck = lastCheckDate {
                            InfoRow(label: "Last Check", value: lastCheck.formatted())
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    // Run Health Check Button
                    Button(action: runHealthCheck) {
                        HStack {
                            if isChecking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            Text(isChecking ? "Checking..." : "Run Health Check")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isChecking)
                    
                    // Issues List
                    if !healthIssues.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Detected Issues", systemImage: "exclamationmark.triangle.fill")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            ForEach(healthIssues) { issue in
                                HealthIssueRow(issue: issue)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Health Check")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
        // Check accelerometer
        if !motionManager.isAccelerometerAvailable {
            healthIssues.append(HealthIssue(
                title: "Accelerometer Unavailable",
                description: "Device's accelerometer is not working",
                severity: .error,
                category: .sensors
            ))
        }
        
        // Check gyroscope
        if !motionManager.isGyroAvailable {
            healthIssues.append(HealthIssue(
                title: "Gyroscope Unavailable",
                description: "Device's gyroscope is not working",
                severity: .error,
                category: .sensors
            ))
        }
    }
    
    private func checkCamera() async {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )
        
        if !discoverySession.devices.isEmpty {
            do {
                let session = AVCaptureSession()
                session.sessionPreset = .photo
                session.beginConfiguration()
                session.commitConfiguration()
            } catch {
                healthIssues.append(HealthIssue(
                    title: "Camera Error",
                    description: "Failed to initialize camera: \(error.localizedDescription)",
                    severity: .error,
                    category: .camera
                ))
            }
        }
    }
    
    private func checkMicrophone() async {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            try audioSession.setActive(false)
        } catch {
            healthIssues.append(HealthIssue(
                title: "Microphone Error",
                description: "Failed to access microphone: \(error.localizedDescription)",
                severity: .error,
                category: .audio
            ))
        }
    }
    
    private func checkSpeakers() async {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            try audioSession.setActive(false)
        } catch {
            healthIssues.append(HealthIssue(
                title: "Speaker Error",
                description: "Failed to access speakers: \(error.localizedDescription)",
                severity: .error,
                category: .audio
            ))
        }
    }
}

// MARK: - Supporting Types

struct HealthIssue: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let severity: IssueSeverity
    let category: IssueCategory
}

enum IssueSeverity {
    case warning
    case error
    case critical
}

enum IssueCategory {
    case storage
    case battery
    case memory
    case network
    case sensors
    case camera
    case audio
    case thermal
}

struct HealthIssueRow: View {
    let issue: HealthIssue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: severityIcon)
                    .foregroundColor(severityColor)
                Text(issue.title)
                    .font(.headline)
            }
            Text(issue.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var severityIcon: String {
        switch issue.severity {
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        case .critical:
            return "exclamationmark.octagon.fill"
        }
    }
    
    private var severityColor: Color {
        switch issue.severity {
        case .warning:
            return .orange
        case .error:
            return .red
        case .critical:
            return .red
        }
    }
} 
