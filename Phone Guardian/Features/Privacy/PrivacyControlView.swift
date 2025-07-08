import SwiftUI
import os.log
import NetworkExtension

struct PrivacyControlView: View {
    @StateObject private var vpnManager = VPNManager()
    @StateObject private var subscriptionManager = INFILOCSubscriptionManager()
    @StateObject private var trafficAnalyzer: TrafficAnalyzer
    
    init() {
        let vpnManager = VPNManager()
        self._vpnManager = StateObject(wrappedValue: vpnManager)
        self._trafficAnalyzer = StateObject(wrappedValue: TrafficAnalyzer(vpnManager: vpnManager))
    }
    @State private var showingVPNExplanation = false
    @State private var showingErrorAlert = false
    @State private var showingSubscription = false
    @State private var showingSettings = false
    @State private var showingDetectionLog = false
    @State private var errorMessage = ""
    @State private var tunnelStatus: [String: Any]?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("INFILOC Privacy Monitor")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Monitor location access attempts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Status Card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundColor(statusColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusText)
                            .font(.headline)
                            .foregroundColor(statusColor)
                        
                        Text(statusDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if vpnManager.connectionStatus == .connecting {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                // Test Environment Indicator
                if vpnManager.isTestEnvironment {
                    HStack {
                        Image(systemName: "iphone.gen3")
                            .foregroundColor(.orange)
                        Text("Test Environment - Full Access Granted")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Connection Details
                if vpnManager.isVPNEnabled {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Connection Status:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(connectionStatusText)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        if let status = tunnelStatus {
                            HStack {
                                Text("Tunnel Health:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Active")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if let retryCount = status["retryCount"] as? Int, retryCount > 0 {
                                HStack {
                                    Text("Retry Attempts:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(retryCount)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Statistics
            if vpnManager.detectionCount > 0 {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                        Text("Detection Statistics")
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Detections")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(vpnManager.detectionCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Last Detection")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let lastTime = vpnManager.lastDetectionTime {
                                Text(lastTime, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            } else {
                                Text("None")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            // Control Buttons
            VStack(spacing: 12) {
                if subscriptionManager.isSubscribed {
                    Button(action: toggleVPN) {
                        HStack {
                            Image(systemName: vpnManager.isVPNEnabled ? "stop.fill" : "play.fill")
                            Text(vpnManager.isVPNEnabled ? "Stop Monitoring" : "Start Monitoring")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vpnManager.isVPNEnabled ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(vpnManager.connectionStatus == .connecting || vpnManager.connectionStatus == .disconnecting)
                    
                    if vpnManager.isVPNEnabled {
                        Button(action: clearDetections) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Detection History")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Settings Button
                    Button(action: { showingSettings = true }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Privacy Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    
                    // Detection Log Button
                    Button(action: { showingDetectionLog = true }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Detection History")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                } else {
                    // Subscription Required
                    VStack(spacing: 12) {
                        Button(action: { showingSubscription = true }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Subscribe to INFILOC")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        VStack(spacing: 8) {
                            Text("🔒 Premium Feature")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("INFILOC requires a subscription to access advanced location monitoring features.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                Button(action: { showingVPNExplanation = true }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("How It Works")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Privacy Monitor")
        .navigationBarTitleDisplayMode(.inline)

        .sheet(isPresented: $showingVPNExplanation) {
            VPNExplanationView(showingPermission: $showingVPNExplanation)
        }
        .sheet(isPresented: $showingSubscription) {
            INFILOCSubscriptionView(subscriptionManager: subscriptionManager)
        }
        .sheet(isPresented: $showingSettings) {
            PrivacySettingsView(vpnManager: vpnManager, trafficAnalyzer: trafficAnalyzer)
        }
        .sheet(isPresented: $showingDetectionLog) {
            DetectionLogView(vpnManager: vpnManager)
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadTunnelStatus()
            // Update subscription status when view appears
            Task {
                await subscriptionManager.updateSubscriptionStatus()
            }
        }
        .onChange(of: vpnManager.connectionStatus) { _ in
            loadTunnelStatus()
        }
        .onChange(of: subscriptionManager.isSubscribed) { isSubscribed in
            // Automatically start VPN if subscription is granted
            if isSubscribed && !vpnManager.isVPNEnabled {
                Task {
                    await vpnManager.startVPN()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var statusIcon: String {
        switch vpnManager.connectionStatus {
        case .connected:
            return "checkmark.shield.fill"
        case .connecting:
            return "arrow.clockwise"
        case .disconnected:
            return "xmark.shield"
        case .disconnecting:
            return "arrow.clockwise"
        case .reasserting:
            return "arrow.clockwise"
        case .invalid:
            return "exclamationmark.shield"
        @unknown default:
            return "questionmark.shield"
        }
    }
    
    private var statusColor: Color {
        switch vpnManager.connectionStatus {
        case .connected:
            return .green
        case .connecting, .disconnecting, .reasserting:
            return .orange
        case .disconnected:
            return .gray
        case .invalid:
            return .red
        @unknown default:
            return .gray
        }
    }
    
    private var statusText: String {
        switch vpnManager.connectionStatus {
        case .connected:
            return "Privacy Protected"
        case .connecting:
            return "Connecting..."
        case .disconnected:
            return "Not Protected"
        case .disconnecting:
            return "Disconnecting..."
        case .reasserting:
            return "Reconnecting..."
        case .invalid:
            return "Configuration Error"
        @unknown default:
            return "Unknown Status"
        }
    }
    
    private var statusDescription: String {
        switch vpnManager.connectionStatus {
        case .connected:
            return "Monitoring location access attempts"
        case .connecting:
            return "Setting up privacy protection"
        case .disconnected:
            return "VPN is not active"
        case .disconnecting:
            return "Stopping privacy protection"
        case .reasserting:
            return "Reconnecting to privacy service"
        case .invalid:
            return "VPN configuration needs attention"
        @unknown default:
            return "Status unknown"
        }
    }
    
    private var connectionStatusText: String {
        switch vpnManager.connectionStatus {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        case .reasserting:
            return "Reasserting"
        case .invalid:
            return "Invalid"
        @unknown default:
            return "Unknown"
        }
    }
    
    // MARK: - Actions
    private func toggleVPN() {
        guard subscriptionManager.isSubscribed else {
            showingSubscription = true
            return
        }
        
        Task {
            if vpnManager.isVPNEnabled {
                await vpnManager.stopVPN()
            } else {
                await vpnManager.startVPN()
            }
        }
    }
    
    private func clearDetections() {
        Task {
            await vpnManager.clearTunnelDetections()
            vpnManager.clearDetections()
        }
    }
    
    private func loadTunnelStatus() {
        Task {
            let status = await vpnManager.getTunnelStatus()
            await MainActor.run {
                self.tunnelStatus = status
            }
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct DetectionRow: View {
    let detection: LocationDetection
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.circle.fill")
                .foregroundColor(.red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(detection.service)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(detection.domain)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(detection.formattedTime)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(detection.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
} 