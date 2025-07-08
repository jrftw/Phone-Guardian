import SwiftUI
import NetworkExtension

struct PrivacyDebugView: View {
    @StateObject private var vpnManager = VPNManager()
    @State private var debugInfo: [String: Any] = [:]
    @State private var debugLog = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("INFILOC Debug Console")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Development and testing tools")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Status Overview
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("System Status")
                            .font(.headline)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatusCard(title: "VPN Status", value: vpnManager.isVPNEnabled ? "Active" : "Inactive", color: vpnManager.isVPNEnabled ? .green : .red)
                        StatusCard(title: "Connection", value: connectionStatusText, color: connectionStatusColor)
                        StatusCard(title: "Detections", value: "\(vpnManager.detectionCount)", color: .blue)
                        StatusCard(title: "Tunnel Health", value: tunnelHealthText, color: tunnelHealthColor)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Debug Actions
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.blue)
                        Text("Debug Actions")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        Button(action: refreshDebugInfo) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Refresh Status")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        Button(action: testTunnelConnection) {
                            HStack {
                                Image(systemName: "network")
                                Text("Test Tunnel Connection")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        Button(action: simulateDetection) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Simulate Detection")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        Button(action: exportDebugLog) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Debug Log")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Debug Information
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.blue)
                        Text("Debug Information")
                            .font(.headline)
                        Spacer()
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(debugInfo.keys.sorted()), id: \.self) { key in
                                if let value = debugInfo[key] {
                                    HStack {
                                        Text(key)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(String(describing: value))")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(4)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Debug Log
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "terminal")
                            .foregroundColor(.blue)
                        Text("Debug Log")
                            .font(.headline)
                        Spacer()
                    }
                    
                    ScrollView {
                        Text(debugLog.isEmpty ? "No debug log available" : debugLog)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 150)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Debug Console")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Debug Action", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            refreshDebugInfo()
        }
    }
    
    // MARK: - Computed Properties
    private var connectionStatusText: String {
        switch vpnManager.connectionStatus {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .disconnecting: return "Disconnecting"
        case .reasserting: return "Reasserting"
        case .invalid: return "Invalid"
        @unknown default: return "Unknown"
        }
    }
    
    private var connectionStatusColor: Color {
        switch vpnManager.connectionStatus {
        case .connected: return .green
        case .connecting, .disconnecting, .reasserting: return .orange
        case .disconnected: return .gray
        case .invalid: return .red
        @unknown default: return .gray
        }
    }
    
    private var tunnelHealthText: String {
        if vpnManager.isVPNEnabled {
            return "Active"
        } else {
            return "Inactive"
        }
    }
    
    private var tunnelHealthColor: Color {
        return vpnManager.isVPNEnabled ? .green : .red
    }
    
    // MARK: - Actions
    private func refreshDebugInfo() {
        debugInfo = vpnManager.getDebugInfo()
        alertMessage = "Debug information refreshed"
        showingAlert = true
    }
    
    private func testTunnelConnection() {
        Task {
            let success = await vpnManager.testTunnelConnection()
            await MainActor.run {
                alertMessage = success ? "Tunnel connection test successful" : "Tunnel connection test failed"
                showingAlert = true
                refreshDebugInfo()
            }
        }
    }
    
    private func simulateDetection() {
        vpnManager.simulateDetection()
        alertMessage = "Detection simulation completed"
        showingAlert = true
        refreshDebugInfo()
    }
    
    private func exportDebugLog() {
        debugLog = vpnManager.exportDebugLog()
        alertMessage = "Debug log exported"
        showingAlert = true
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        PrivacyDebugView()
    }
} 