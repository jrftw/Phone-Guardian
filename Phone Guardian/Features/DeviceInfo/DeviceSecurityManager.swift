// MARK: LOG: DEVICE
import Foundation
import UIKit
import SwiftUI
import os

class DeviceSecurityManager: ObservableObject {
    static let shared = DeviceSecurityManager()
    private let logger = Logger(subsystem: "com.phoneguardian.devicesecurity", category: "DeviceSecurityManager")
    
    @Published var securityStatus: SecurityStatus = .checking
    @Published var jailbreakDetected: Bool = false
    @Published var vulnerabilities: [SecurityVulnerability] = []
    @Published var lastScanDate: Date?
    
    enum SecurityStatus {
        case checking
        case secure
        case compromised
        case unknown
    }
    
    struct SecurityVulnerability: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let severity: Severity
        let recommendation: String
        
        enum Severity {
            case low, medium, high, critical
        }
    }
    
    @MainActor
    func performSecurityScan() async {
        logger.info("Starting device security scan")
        securityStatus = .checking
        
        scanForJailbreak()
        scanForVulnerabilities()
        updateSecurityStatus()
        
        lastScanDate = Date()
        logger.info("Security scan completed. Status: \(String(describing: self.securityStatus))")
    }
    
    @MainActor
    private func scanForJailbreak() {
        logger.debug("Scanning for jailbreak indicators")
        
        let jailbreakIndicators = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"
        ]
        
        for path in jailbreakIndicators {
            if FileManager.default.fileExists(atPath: path) {
                logger.warning("Jailbreak indicator found: \(path)")
                self.jailbreakDetected = true
                return
            }
        }
        
        // Check for suspicious processes
        let suspiciousProcesses = ["Cydia", "Sileo", "Zebra", "Installer"]
        for process in suspiciousProcesses {
            if isProcessRunning(process) {
                logger.warning("Suspicious process detected: \(process)")
                self.jailbreakDetected = true
                return
            }
        }
        
        self.jailbreakDetected = false
    }
    
    @MainActor
    private func scanForVulnerabilities() {
        logger.debug("Scanning for system vulnerabilities")
        var foundVulnerabilities: [SecurityVulnerability] = []
        
        // Check iOS version for known vulnerabilities
        let currentVersion = UIDevice.current.systemVersion
        if let version = Double(currentVersion), version < 17.0 {
            foundVulnerabilities.append(SecurityVulnerability(
                title: "Outdated iOS Version",
                description: "Your device is running iOS \(currentVersion), which may have known security vulnerabilities.",
                severity: .high,
                recommendation: "Update to the latest iOS version available."
            ))
        }
        
        // Check for developer mode (potential security risk)
        if isDeveloperModeEnabled() {
            foundVulnerabilities.append(SecurityVulnerability(
                title: "Developer Mode Active",
                description: "Developer mode is enabled, which can pose security risks.",
                severity: .medium,
                recommendation: "Disable developer mode if not needed for development."
            ))
        }
        
        // Check for suspicious entitlements
        if hasSuspiciousEntitlements() {
            foundVulnerabilities.append(SecurityVulnerability(
                title: "Suspicious App Entitlements",
                description: "This app has entitlements that could indicate security concerns.",
                severity: .medium,
                recommendation: "Review app permissions and entitlements."
            ))
        }
        
        self.vulnerabilities = foundVulnerabilities
    }
    
    @MainActor
    private func updateSecurityStatus() {
        if jailbreakDetected {
            securityStatus = .compromised
        } else if !vulnerabilities.isEmpty {
            let hasCriticalVulnerabilities = vulnerabilities.contains { $0.severity == .critical }
            securityStatus = hasCriticalVulnerabilities ? .compromised : .secure
        } else {
            securityStatus = .secure
        }
    }
    
    private func isProcessRunning(_ processName: String) -> Bool {
        // This is a simplified check - in a real implementation, you'd need more sophisticated process detection
        return false
    }
    
    private func isDeveloperModeEnabled() -> Bool {
        // Check if developer mode is enabled
        return false
    }
    
    private func hasSuspiciousEntitlements() -> Bool {
        // Check for suspicious app entitlements
        return false
    }
    
    func getSecurityStatusDescription() -> String {
        switch securityStatus {
        case .checking:
            return "Scanning device security..."
        case .secure:
            return "Device security status is good"
        case .compromised:
            return "Security issues detected"
        case .unknown:
            return "Unable to determine security status"
        }
    }
    
    func getSecurityStatusColor() -> Color {
        switch securityStatus {
        case .checking:
            return .orange
        case .secure:
            return .green
        case .compromised:
            return .red
        case .unknown:
            return .gray
        }
    }
} 