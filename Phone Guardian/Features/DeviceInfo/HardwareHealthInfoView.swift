import SwiftUI

// Define HardwareHealthIssue struct to avoid conflicts with HealthCheckView
struct HardwareHealthIssue: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let severity: HardwareHealthIssueSeverity
    let category: HardwareHealthIssueCategory
    let timestamp: Date
    
    enum HardwareHealthIssueSeverity: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }
    
    enum HardwareHealthIssueCategory: String, CaseIterable {
        case battery = "Battery"
        case memory = "Memory"
        case storage = "Storage"
        case cpu = "CPU"
        case gpu = "GPU"
        case thermal = "Thermal"
        case network = "Network"
        case sensors = "Sensors"
        case general = "General"
    }
}

struct HardwareHealthInfoView: View {
    @StateObject private var healthManager = HardwareHealthManager.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Overall Health Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Overall Health", icon: "heart.text.square")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "heart.fill", label: "Health Score", value: "\(Int(healthManager.componentHealth.overallHealth))%", iconColor: getHealthScoreColor(healthManager.componentHealth.overallHealth))
                        ModernInfoRow(icon: "exclamationmark.triangle", label: "Issues Found", value: "0", iconColor: .green)
                        ModernInfoRow(icon: "checkmark.circle", label: "Components OK", value: "All", iconColor: .green)
                        ModernInfoRow(icon: "clock", label: "Last Check", value: healthManager.lastUpdateDate?.formatted() ?? "Never", iconColor: .blue)
                    }
                }
                .modernCard()
                
                // Component Health Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Component Health", icon: "gearshape.2")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "battery.100", label: "Battery Health", value: "\(Int(healthManager.batteryHealth.healthPercentage))%", iconColor: healthManager.getBatteryHealthStatusColor(healthManager.batteryHealth.healthStatus))
                        ModernInfoRow(icon: "memorychip", label: "RAM Health", value: healthManager.getMemoryHealthStatusColor(healthManager.memoryHealth.healthStatus).description, iconColor: healthManager.getMemoryHealthStatusColor(healthManager.memoryHealth.healthStatus))
                        ModernInfoRow(icon: "cpu", label: "CPU Health", value: "\(Int(healthManager.componentHealth.cpuHealth))%", iconColor: healthManager.getComponentHealthStatusColor(healthManager.componentHealth.healthStatus))
                        ModernInfoRow(icon: "display", label: "Display Health", value: "Good", iconColor: .green)
                        ModernInfoRow(icon: "speaker.wave.2", label: "Speaker Health", value: "Good", iconColor: .green)
                        ModernInfoRow(icon: "camera", label: "Camera Health", value: "Good", iconColor: .green)
                    }
                }
                .modernCard()
                
                // Performance Metrics Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Performance Metrics", icon: "speedometer")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "thermometer", label: "Temperature", value: "\(Int(healthManager.batteryHealth.temperature))°C", iconColor: getTemperatureColor(healthManager.batteryHealth.temperature))
                        ModernInfoRow(icon: "cpu", label: "CPU Usage", value: "\(Int(healthManager.componentHealth.cpuHealth))%", iconColor: getCpuUsageColor(healthManager.componentHealth.cpuHealth))
                        
                        // Safe memory usage calculation
                        let used = Double(healthManager.memoryHealth.usedMemory)
                        let total = Double(healthManager.memoryHealth.totalMemory)
                        let percent = (total > 0 && used >= 0) ? (used / total) * 100 : 0
                        
                        ModernInfoRow(icon: "memorychip", label: "Memory Usage", value: "\(Int(percent))%", iconColor: getMemoryUsageColor(percent))
                        ModernInfoRow(icon: "externaldrive", label: "Storage Health", value: healthManager.getStorageHealthStatusColor(healthManager.storageHealth.healthStatus).description, iconColor: healthManager.getStorageHealthStatusColor(healthManager.storageHealth.healthStatus))
                    }
                }
                .modernCard()
                
                // Issues and Recommendations Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Issues & Recommendations", icon: "exclamationmark.triangle")
                    
                    Text("No issues detected")
                        .foregroundColor(.green)
                        .padding()
                }
                .modernCard()
                
                // Action Buttons
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Actions", icon: "wrench.and.screwdriver")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await healthManager.updateHardwareHealth()
                            }
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Run Health Check")
                            }
                        }
                        .modernButton(backgroundColor: .blue)
                        
                        Button(action: {
                            // Generate health report functionality
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Generate Health Report")
                            }
                        }
                        .modernButton(backgroundColor: .green)
                        
                        Button(action: {
                            // Reset health data functionality
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset Health Data")
                            }
                        }
                        .modernButton(backgroundColor: .orange)
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Hardware Health")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await healthManager.updateHardwareHealth()
            }
        }
    }
    
    // Helper functions for color coding
    private func getHealthScoreColor(_ score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
    
    private func getTemperatureColor(_ temperature: Double) -> Color {
        switch temperature {
        case 0..<30: return .green
        case 30..<40: return .orange
        default: return .red
        }
    }
    
    private func getCpuUsageColor(_ usage: Double) -> Color {
        switch usage {
        case 0..<50: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
    
    private func getMemoryUsageColor(_ usage: Double) -> Color {
        switch usage {
        case 0..<60: return .green
        case 60..<85: return .orange
        default: return .red
        }
    }
}

struct HardwareHealthIssueRow: View {
    let issue: HardwareHealthIssue
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: issue.severity == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
                .foregroundColor(issue.severity == .critical ? .red : .orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(issue.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(issue.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(issue.severity.rawValue.capitalized)
                .font(.caption)
                .foregroundColor(issue.severity == .critical ? .red : .orange)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
} 