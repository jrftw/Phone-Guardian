import SwiftUI

struct SystemLogsInfoView: View {
    @StateObject private var logManager = SystemLogsManager.shared
    @State private var selectedLogLevel: SystemLogsManager.SystemLogEntry.LogSeverity = .info
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Log Statistics Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Log Statistics", icon: "doc.text")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "doc.text", label: "Total Logs", value: "\(logManager.systemLogs.count)", iconColor: .blue)
                        ModernInfoRow(icon: "exclamationmark.triangle", label: "Error Logs", value: "\(logManager.logStatistics.errorCount)", iconColor: .red)
                        ModernInfoRow(icon: "exclamationmark", label: "Warning Logs", value: "\(logManager.logStatistics.warningCount)", iconColor: .orange)
                        ModernInfoRow(icon: "info.circle", label: "Info Logs", value: "\(logManager.logStatistics.logsBySeverity[.info] ?? 0)", iconColor: .green)
                        ModernInfoRow(icon: "clock", label: "Last Updated", value: logManager.lastUpdateDate?.formatted() ?? "Never", iconColor: .purple)
                    }
                }
                .modernCard()
                
                // Log Filter Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Filter Logs", icon: "line.3.horizontal.decrease.circle")
                    
                    Picker("Log Level", selection: $selectedLogLevel) {
                        Text("All").tag(SystemLogsManager.SystemLogEntry.LogSeverity.info)
                        Text("Errors").tag(SystemLogsManager.SystemLogEntry.LogSeverity.error)
                        Text("Warnings").tag(SystemLogsManager.SystemLogEntry.LogSeverity.warning)
                        Text("Info").tag(SystemLogsManager.SystemLogEntry.LogSeverity.info)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .modernCard()
                
                // System Logs Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "System Logs", icon: "doc.text")
                    
                    if logManager.systemLogs.isEmpty {
                        Text("No logs available")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(logManager.systemLogs.prefix(20)) { log in
                                LogEntryRow(log: log)
                            }
                        }
                    }
                }
                .modernCard()
                
                // Log Categories Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Log Categories", icon: "folder")
                    
                    LazyVStack(spacing: 8) {
                        ForEach(Array(logManager.logStatistics.logsByCategory.keys.sorted()), id: \.self) { category in
                            LogCategoryRow(category: category, count: logManager.logStatistics.logsByCategory[category] ?? 0)
                        }
                    }
                }
                .modernCard()
                
                // Action Buttons
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Actions", icon: "wrench.and.screwdriver")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await logManager.startMonitoring()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Start Monitoring")
                            }
                        }
                        .modernButton(backgroundColor: .blue)
                        
                        Button(action: {
                            logManager.stopMonitoring()
                        }) {
                            HStack {
                                Image(systemName: "stop.circle")
                                Text("Stop Monitoring")
                            }
                        }
                        .modernButton(backgroundColor: .red)
                        
                        Button(action: {
                            // Export logs functionality
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Logs")
                            }
                        }
                        .modernButton(backgroundColor: .green)
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("System Logs")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await logManager.startMonitoring()
            }
        }
    }
}

struct LogEntryRow: View {
    let log: SystemLogsManager.SystemLogEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: logLevelIcon)
                .foregroundColor(logLevelColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("\(log.category) • \(formatDate(log.timestamp))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(log.severity.rawValue.capitalized)
                .font(.caption)
                .foregroundColor(logLevelColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var logLevelIcon: String {
        switch log.severity {
        case .error, .fault, .critical: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.triangle"
        case .info, .notice: return "info.circle"
        case .debug: return "ladybug"
        }
    }
    
    private var logLevelColor: Color {
        return log.severity.color
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct LogCategoryRow: View {
    let category: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder")
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(count) logs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(Date().formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
} 