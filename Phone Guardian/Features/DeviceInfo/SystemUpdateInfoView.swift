import SwiftUI

// Define UpdateRecord struct since it's not defined in SystemUpdateManager
struct UpdateRecord: Identifiable {
    let id = UUID()
    let version: String
    let installDate: String
    let status: UpdateStatus
    let size: String
    let description: String
    
    enum UpdateStatus: String, CaseIterable {
        case installed = "Installed"
        case failed = "Failed"
        case pending = "Pending"
    }
}

struct SystemUpdateInfoView: View {
    @StateObject private var updateManager = SystemUpdateManager.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Current System Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Current System", icon: "gear")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "iphone", label: "iOS Version", value: updateManager.currentVersion, iconColor: .blue)
                        ModernInfoRow(icon: "number", label: "Build Number", value: updateManager.buildNumber, iconColor: .gray)
                        ModernInfoRow(icon: "calendar", label: "Release Date", value: updateManager.lastUpdateInstalled?.releaseDate.formatted() ?? "Unknown", iconColor: .green)
                        ModernInfoRow(icon: "checkmark.circle", label: "System Status", value: updateManager.getUpdateStatusDescription(), iconColor: updateManager.getUpdateStatusColor())
                    }
                }
                .modernCard()
                
                // Available Updates Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Available Updates", icon: "arrow.clockwise.circle")
                    
                    if updateManager.availableUpdates.isEmpty {
                        Text("No updates available")
                            .foregroundColor(.green)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(updateManager.availableUpdates) { update in
                                UpdateRow(update: update)
                            }
                        }
                    }
                }
                .modernCard()
                
                // Update Settings Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Update Settings", icon: "gear")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "wifi", label: "Auto Update", value: "Disabled", iconColor: .red)
                        ModernInfoRow(icon: "network", label: "Wi-Fi Only", value: "Yes", iconColor: .blue)
                        ModernInfoRow(icon: "battery.100", label: "Battery Level", value: "50%", iconColor: .green)
                        ModernInfoRow(icon: "clock", label: "Last Check", value: updateManager.lastCheckDate?.formatted() ?? "Never", iconColor: .blue)
                    }
                }
                .modernCard()
                
                // Update History Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Update History", icon: "clock.arrow.circlepath")
                    
                    if updateManager.versionHistory.isEmpty {
                        Text("No update history available")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(updateManager.versionHistory.prefix(5)) { update in
                                UpdateHistoryRow(update: UpdateRecord(
                                    version: update.version,
                                    installDate: update.releaseDate.formatted(),
                                    status: .installed,
                                    size: update.size,
                                    description: update.description
                                ))
                            }
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
                                await updateManager.checkForUpdates()
                            }
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Check for Updates")
                            }
                        }
                        .modernButton(backgroundColor: .blue)
                        
                        Button(action: {
                            // Download latest update functionality
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                Text("Download Latest Update")
                            }
                        }
                        .modernButton(backgroundColor: .green)
                        .disabled(updateManager.availableUpdates.isEmpty)
                        
                        Button(action: {
                            // Open update settings functionality
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Open Update Settings")
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
        .navigationTitle("System Updates")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await updateManager.checkForUpdates()
            }
        }
    }
}

struct UpdateRow: View {
    let update: SystemUpdateManager.SystemUpdate
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.clockwise.circle")
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("iOS \(update.version)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(update.size) • \(update.releaseDate.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(update.isMajorUpdate ? "Major" : "Minor")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

struct UpdateHistoryRow: View {
    let update: UpdateRecord
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("iOS \(update.version)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Installed on \(update.installDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(update.status.rawValue.capitalized)
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
} 