// MARK: LOG: HEALTH
import Foundation
import SwiftUI
import os
import OSLog

class SystemLogsManager: ObservableObject {
    static let shared = SystemLogsManager()
    private let logger = Logger(subsystem: "com.phoneguardian.systemlogs", category: "SystemLogsManager")
    
    @Published var systemLogs: [SystemLogEntry] = []
    @Published var filteredLogs: [SystemLogEntry] = []
    @Published var logStatistics: LogStatistics = LogStatistics()
    @Published var monitoringStatus: MonitoringStatus = .stopped
    @Published var filterSettings: FilterSettings = FilterSettings()
    @Published var lastUpdateDate: Date?
    
    private var monitoringTimer: Timer?
    private let maxLogEntries = 1000
    
    enum MonitoringStatus {
        case stopped, running, error
    }
    
    struct SystemLogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let subsystem: String
        let category: String
        let severity: LogSeverity
        let message: String
        let processName: String
        let threadID: UInt64
        let sourceFile: String?
        let lineNumber: Int?
        
        enum LogSeverity: String, CaseIterable {
            case debug = "Debug"
            case info = "Info"
            case notice = "Notice"
            case warning = "Warning"
            case error = "Error"
            case fault = "Fault"
            case critical = "Critical"
            
            var color: Color {
                switch self {
                case .debug:
                    return .gray
                case .info:
                    return .blue
                case .notice:
                    return .green
                case .warning:
                    return .orange
                case .error:
                    return .red
                case .fault:
                    return .purple
                case .critical:
                    return .black
                }
            }
        }
    }
    
    struct LogStatistics {
        var totalLogs: Int = 0
        var logsBySeverity: [SystemLogEntry.LogSeverity: Int] = [:]
        var logsBySubsystem: [String: Int] = [:]
        var logsByCategory: [String: Int] = [:]
        var errorCount: Int = 0
        var warningCount: Int = 0
        var criticalCount: Int = 0
    }
    
    struct FilterSettings {
        var selectedSeverities: Set<SystemLogEntry.LogSeverity> = Set(SystemLogEntry.LogSeverity.allCases)
        var selectedSubsystems: Set<String> = []
        var selectedCategories: Set<String> = []
        var searchText: String = ""
        var timeRange: TimeRange = .all
        var showSystemLogs: Bool = true
        var showAppLogs: Bool = true
        
        enum TimeRange {
            case all, lastHour, lastDay, lastWeek, custom(Date, Date)
        }
    }
    
    @MainActor
    func startMonitoring() async {
        logger.info("Starting system logs monitoring")
        monitoringStatus = .running
        
        await loadHistoricalLogs()
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                await SystemLogsManager.shared.updateSystemLogs()
            }
        }
        
        logger.info("System logs monitoring started")
    }
    
    @MainActor
    func stopMonitoring() {
        logger.info("Stopping system logs monitoring")
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        monitoringStatus = .stopped
    }
    
    @MainActor
    private func loadHistoricalLogs() async {
        logger.debug("Loading historical system logs")
        
        // In a real implementation, you would:
        // 1. Query the system log store for historical entries
        // 2. Parse and format the log entries
        // 3. Apply initial filtering
        
        // For now, we'll simulate historical logs
        let simulatedLogs = await simulateHistoricalLogs()
        
        self.systemLogs = simulatedLogs
        await self.applyFilters()
        self.updateStatistics()
    }
    
    @MainActor
    private func updateSystemLogs() async {
        logger.debug("Updating system logs")
        
        // In a real implementation, you would:
        // 1. Query for new log entries since last update
        // 2. Parse and add new entries to the list
        // 3. Update statistics and apply filters
        
        // For now, we'll simulate new log entries
        let newLogs = await simulateNewLogEntries()
        
        self.systemLogs.append(contentsOf: newLogs)
        
        // Keep only the last maxLogEntries
        if self.systemLogs.count > self.maxLogEntries {
            self.systemLogs.removeFirst(self.systemLogs.count - self.maxLogEntries)
        }
        
        await self.applyFilters()
        self.updateStatistics()
        self.lastUpdateDate = Date()
    }
    
    private func simulateHistoricalLogs() async -> [SystemLogEntry] {
        let subsystems = ["com.apple.system", "com.apple.network", "com.apple.storage", "com.apple.power", "com.apple.memory"]
        let categories = ["general", "network", "storage", "power", "memory", "performance"]
        let severities: [SystemLogEntry.LogSeverity] = [.info, .notice, .warning, .error]
        let processNames = ["kernel", "launchd", "SpringBoard", "backupd", "mDNSResponder"]
        
        var logs: [SystemLogEntry] = []
        let now = Date()
        
        for _ in 0..<100 {
            let timestamp = now.addingTimeInterval(-Double.random(in: 0...3600)) // Last hour
            let subsystem = subsystems.randomElement() ?? "com.apple.system"
            let category = categories.randomElement() ?? "general"
            let severity = severities.randomElement() ?? .info
            let processName = processNames.randomElement() ?? "unknown"
            
            let log = SystemLogEntry(
                timestamp: timestamp,
                subsystem: subsystem,
                category: category,
                severity: severity,
                message: generateLogMessage(subsystem: subsystem, category: category, severity: severity),
                processName: processName,
                threadID: UInt64.random(in: 1...1000),
                sourceFile: nil,
                lineNumber: nil
            )
            
            logs.append(log)
        }
        
        return logs.sorted { $0.timestamp > $1.timestamp }
    }
    
    private func simulateNewLogEntries() async -> [SystemLogEntry] {
        let subsystems = ["com.apple.system", "com.apple.network", "com.apple.storage"]
        let categories = ["general", "network", "storage"]
        let severities: [SystemLogEntry.LogSeverity] = [.info, .notice, .warning]
        let processNames = ["kernel", "launchd", "SpringBoard"]
        
        var newLogs: [SystemLogEntry] = []
        let count = Int.random(in: 1...5)
        
        for _ in 0..<count {
            let subsystem = subsystems.randomElement() ?? "com.apple.system"
            let category = categories.randomElement() ?? "general"
            let severity = severities.randomElement() ?? .info
            let processName = processNames.randomElement() ?? "unknown"
            
            let log = SystemLogEntry(
                timestamp: Date(),
                subsystem: subsystem,
                category: category,
                severity: severity,
                message: generateLogMessage(subsystem: subsystem, category: category, severity: severity),
                processName: processName,
                threadID: UInt64.random(in: 1...1000),
                sourceFile: nil,
                lineNumber: nil
            )
            
            newLogs.append(log)
        }
        
        return newLogs
    }
    
    private func generateLogMessage(subsystem: String, category: String, severity: SystemLogEntry.LogSeverity) -> String {
        let messages = [
            "System operation completed successfully",
            "Network connection established",
            "Storage operation in progress",
            "Power management event occurred",
            "Memory allocation completed",
            "Background task started",
            "User interaction detected",
            "System resource accessed",
            "Configuration updated",
            "Performance metric recorded"
        ]
        
        return messages.randomElement() ?? "System log entry"
    }
    
    @MainActor
    func applyFilters() async {
        logger.debug("Applying log filters")
        
        var filtered = systemLogs
        
        // Filter by severity
        filtered = filtered.filter { filterSettings.selectedSeverities.contains($0.severity) }
        
        // Filter by subsystem
        if !filterSettings.selectedSubsystems.isEmpty {
            filtered = filtered.filter { filterSettings.selectedSubsystems.contains($0.subsystem) }
        }
        
        // Filter by category
        if !filterSettings.selectedCategories.isEmpty {
            filtered = filtered.filter { filterSettings.selectedCategories.contains($0.category) }
        }
        
        // Filter by search text
        if !filterSettings.searchText.isEmpty {
            filtered = filtered.filter { log in
                log.message.localizedCaseInsensitiveContains(filterSettings.searchText) ||
                log.subsystem.localizedCaseInsensitiveContains(filterSettings.searchText) ||
                log.category.localizedCaseInsensitiveContains(filterSettings.searchText)
            }
        }
        
        // Filter by time range
        filtered = filterByTimeRange(filtered)
        
        self.filteredLogs = filtered
    }
    
    private func filterByTimeRange(_ logs: [SystemLogEntry]) -> [SystemLogEntry] {
        let now = Date()
        
        switch filterSettings.timeRange {
        case .all:
            return logs
        case .lastHour:
            let oneHourAgo = now.addingTimeInterval(-3600)
            return logs.filter { $0.timestamp >= oneHourAgo }
        case .lastDay:
            let oneDayAgo = now.addingTimeInterval(-86400)
            return logs.filter { $0.timestamp >= oneDayAgo }
        case .lastWeek:
            let oneWeekAgo = now.addingTimeInterval(-604800)
            return logs.filter { $0.timestamp >= oneWeekAgo }
        case .custom(let start, let end):
            return logs.filter { $0.timestamp >= start && $0.timestamp <= end }
        }
    }
    
    @MainActor
    private func updateStatistics() {
        logger.debug("Updating log statistics")
        
        var statistics = LogStatistics()
        
        for log in systemLogs {
            statistics.totalLogs += 1
            
            // Count by severity
            statistics.logsBySeverity[log.severity, default: 0] += 1
            
            // Count by subsystem
            statistics.logsBySubsystem[log.subsystem, default: 0] += 1
            
            // Count by category
            statistics.logsByCategory[log.category, default: 0] += 1
            
            // Count specific severities
            switch log.severity {
            case .error, .fault, .critical:
                statistics.errorCount += 1
            case .warning:
                statistics.warningCount += 1
            default:
                break
            }
        }
        
        self.logStatistics = statistics
    }
    
    func getMonitoringStatusDescription() -> String {
        switch monitoringStatus {
        case .stopped:
            return "Log monitoring stopped"
        case .running:
            return "Log monitoring active"
        case .error:
            return "Log monitoring error"
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
    
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    func getLogEntryDescription(_ entry: SystemLogEntry) -> String {
        return "[\(entry.subsystem)] [\(entry.category)] \(entry.message)"
    }
    
    func getAvailableSubsystems() -> [String] {
        return Array(Set(systemLogs.map { $0.subsystem })).sorted()
    }
    
    func getAvailableCategories() -> [String] {
        return Array(Set(systemLogs.map { $0.category })).sorted()
    }
    
    func clearLogs() {
        logger.info("Clearing system logs")
        systemLogs.removeAll()
        filteredLogs.removeAll()
        logStatistics = LogStatistics()
    }
    
    func exportLogs() -> String {
        var export = "System Logs Export\n"
        export += "Generated: \(Date())\n"
        export += "Total Entries: \(systemLogs.count)\n\n"
        
        for log in systemLogs {
            export += "[\(formatTimestamp(log.timestamp))] [\(log.severity.rawValue)] [\(log.subsystem)] [\(log.category)] \(log.message)\n"
        }
        
        return export
    }
    
    func getLogsBySeverity(_ severity: SystemLogEntry.LogSeverity) -> [SystemLogEntry] {
        return systemLogs.filter { $0.severity == severity }
    }
    
    func getLogsBySubsystem(_ subsystem: String) -> [SystemLogEntry] {
        return systemLogs.filter { $0.subsystem == subsystem }
    }
    
    func getLogsByCategory(_ category: String) -> [SystemLogEntry] {
        return systemLogs.filter { $0.category == category }
    }
    
    func getRecentErrors(limit: Int = 10) -> [SystemLogEntry] {
        return systemLogs.filter { $0.severity == .error || $0.severity == .fault || $0.severity == .critical }
            .prefix(limit)
            .map { $0 }
    }
    
    func getRecentWarnings(limit: Int = 10) -> [SystemLogEntry] {
        return systemLogs.filter { $0.severity == .warning }
            .prefix(limit)
            .map { $0 }
    }
} 