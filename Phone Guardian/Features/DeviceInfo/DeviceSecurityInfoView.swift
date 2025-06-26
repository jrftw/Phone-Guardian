import SwiftUI
import LocalAuthentication

struct DeviceSecurityInfoView: View {
    @StateObject private var securityManager = DeviceSecurityManager.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Security Status Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Security Status", icon: "lock.shield")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "lock.fill", label: "Device Security", value: securityManager.getSecurityStatusDescription(), iconColor: securityManager.getSecurityStatusColor())
                        ModernInfoRow(icon: "exclamationmark.triangle", label: "Jailbreak Detection", value: securityManager.jailbreakDetected ? "Detected" : "Not Detected", iconColor: securityManager.jailbreakDetected ? .red : .green)
                        ModernInfoRow(icon: "clock", label: "Last Scan", value: formatDate(securityManager.lastScanDate), iconColor: .blue)
                    }
                }
                .modernCard()
                
                // Vulnerabilities Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Security Vulnerabilities", icon: "exclamationmark.triangle")
                    
                    if securityManager.vulnerabilities.isEmpty {
                        Text("No vulnerabilities detected")
                            .foregroundColor(.green)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(securityManager.vulnerabilities) { vulnerability in
                                VulnerabilityRow(vulnerability: vulnerability)
                            }
                        }
                    }
                }
                .modernCard()
                
                // Security Recommendations
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Security Recommendations", icon: "checkmark.shield")
                    
                    LazyVStack(spacing: 12) {
                        ForEach(getSecurityRecommendations(), id: \.self) { recommendation in
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                    .font(.title3)
                                
                                Text(recommendation)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
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
                                await securityManager.performSecurityScan()
                            }
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Run Security Scan")
                            }
                        }
                        .modernButton(backgroundColor: .blue)
                        
                        Button(action: {
                            openSecuritySettings()
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Open Security Settings")
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
        .navigationTitle("Device Security")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await securityManager.performSecurityScan()
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getSecurityRecommendations() -> [String] {
        var recommendations: [String] = []
        
        if securityManager.jailbreakDetected {
            recommendations.append("Remove jailbreak to restore device security")
        }
        
        if securityManager.vulnerabilities.contains(where: { $0.severity == .critical }) {
            recommendations.append("Address critical security vulnerabilities immediately")
        }
        
        if securityManager.vulnerabilities.contains(where: { $0.severity == .high }) {
            recommendations.append("Update iOS to the latest version")
        }
        
        if recommendations.isEmpty {
            recommendations.append("Keep your device updated with the latest security patches")
            recommendations.append("Enable automatic updates for enhanced security")
        }
        
        return recommendations
    }
    
    private func openSecuritySettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct VulnerabilityRow: View {
    let vulnerability: DeviceSecurityManager.SecurityVulnerability
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: severityIcon)
                .foregroundColor(severityColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vulnerability.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(vulnerability.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                Text("Recommendation: \(vulnerability.recommendation)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(severityText)
                .font(.caption)
                .foregroundColor(severityColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(severityColor.opacity(0.2))
                )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var severityIcon: String {
        switch vulnerability.severity {
        case .critical: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.triangle"
        case .medium: return "exclamationmark.circle"
        case .low: return "info.circle"
        }
    }
    
    private var severityColor: Color {
        switch vulnerability.severity {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
    
    private var severityText: String {
        switch vulnerability.severity {
        case .critical: return "Critical"
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
} 