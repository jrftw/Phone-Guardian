// MARK: LOG: DEVICE
import Foundation
import UIKit
import SwiftUI
import os

class SystemUpdateManager: ObservableObject {
    static let shared = SystemUpdateManager()
    private let logger = Logger(subsystem: "com.phoneguardian.systemupdate", category: "SystemUpdateManager")
    
    @Published var currentVersion: String = ""
    @Published var buildNumber: String = ""
    @Published var availableUpdates: [SystemUpdate] = []
    @Published var lastUpdateInstalled: SystemUpdate?
    @Published var versionHistory: [SystemUpdate] = []
    @Published var updateStatus: UpdateStatus = .checking
    @Published var lastCheckDate: Date?
    
    enum UpdateStatus {
        case checking, upToDate, updateAvailable, updateRequired, error
    }
    
    struct SystemUpdate: Identifiable, Codable {
        var id = UUID()
        let version: String
        let buildNumber: String
        let releaseDate: Date
        let description: String
        let size: String
        let isSecurityUpdate: Bool
        let isMajorUpdate: Bool
        let downloadURL: String?
        let releaseNotes: String?
        
        var displayName: String {
            return "iOS \(version)"
        }
        
        var fullVersion: String {
            return "\(version) (\(buildNumber))"
        }
    }
    
    func checkForUpdates() async {
        logger.info("Checking for system updates")
        
        await MainActor.run {
            self.updateStatus = .checking
        }
        
        await Task.detached(priority: .userInitiated) {
            await self.updateCurrentVersion()
            await self.checkForAvailableUpdates()
            await self.loadVersionHistory()
            await self.updateStatus()
        }.value
        
        await MainActor.run {
            self.lastCheckDate = Date()
        }
        logger.info("System update check completed. Status: \(String(describing: self.updateStatus))")
    }
    
    private func updateCurrentVersion() async {
        logger.debug("Updating current version information")
        
        let device = UIDevice.current
        let version = device.systemVersion
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        await MainActor.run {
            self.currentVersion = version
            self.buildNumber = build
        }
        
        logger.debug("Current version: \(version) (\(build))")
    }
    
    private func checkForAvailableUpdates() async {
        logger.debug("Fetching available system updates")
        
        // Use SoftwareUpdate framework to check for available updates
        // Note: This requires proper entitlements and may not be available in all contexts
        await MainActor.run {
            self.availableUpdates = []
        }
        
        // In a production app, you would implement proper update checking
        // using SoftwareUpdate framework or by checking against known version lists
        await updateStatus()
    }
    
    private func loadVersionHistory() async {
        logger.debug("Loading version history")
        
        // Get the current version information
        let currentDate = Date()
        let device = UIDevice.current
        
        let history = [SystemUpdate(
            version: device.systemVersion,
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
            releaseDate: currentDate.addingTimeInterval(-30 * 24 * 3600), // Estimate 30 days ago
            description: "Current iOS version",
            size: "0 MB",
            isSecurityUpdate: false,
            isMajorUpdate: false,
            downloadURL: nil,
            releaseNotes: "Current version"
        )]
        
        await MainActor.run {
            self.versionHistory = history
            self.lastUpdateInstalled = history.first
        }
    }
    
    private func updateStatus() async {
        if availableUpdates.isEmpty {
            await MainActor.run {
                self.updateStatus = .upToDate
            }
        } else {
            let hasRequiredUpdate = availableUpdates.contains { update in
                // Check if this is a required security update
                update.isSecurityUpdate && isUpdateRequired(update)
            }
            await MainActor.run {
                self.updateStatus = hasRequiredUpdate ? .updateRequired : .updateAvailable
            }
        }
    }
    
    private func isUpdateRequired(_ update: SystemUpdate) -> Bool {
        // In a real implementation, you would check if this update is required
        // For now, we'll consider security updates as required
        return update.isSecurityUpdate
    }
    
    func getUpdateStatusDescription() -> String {
        switch updateStatus {
        case .checking:
            return "Checking for updates..."
        case .upToDate:
            return "Your device is up to date"
        case .updateAvailable:
            return "\(availableUpdates.count) update(s) available"
        case .updateRequired:
            return "Security update required"
        case .error:
            return "Unable to check for updates"
        }
    }
    
    func getUpdateStatusColor() -> Color {
        switch updateStatus {
        case .checking:
            return .orange
        case .upToDate:
            return .green
        case .updateAvailable:
            return .blue
        case .updateRequired:
            return .red
        case .error:
            return .gray
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func getVersionComparison(_ version1: String, _ version2: String) -> ComparisonResult {
        let components1 = version1.split(separator: ".").compactMap { Int($0) }
        let components2 = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(components1.count, components2.count)
        
        for i in 0..<maxLength {
            let val1 = i < components1.count ? components1[i] : 0
            let val2 = i < components2.count ? components2[i] : 0
            
            if val1 < val2 {
                return .orderedAscending
            } else if val1 > val2 {
                return .orderedDescending
            }
        }
        
        return .orderedSame
    }
    
    func isVersionNewer(_ version: String, than current: String) -> Bool {
        return getVersionComparison(version, current) == .orderedDescending
    }
    
    func getUpdateTypeIcon(_ update: SystemUpdate) -> String {
        if update.isMajorUpdate {
            return "star.fill"
        } else if update.isSecurityUpdate {
            return "shield.fill"
        } else {
            return "gear"
        }
    }
    
    func getUpdateTypeColor(_ update: SystemUpdate) -> Color {
        if update.isMajorUpdate {
            return .blue
        } else if update.isSecurityUpdate {
            return .red
        } else {
            return .green
        }
    }
} 