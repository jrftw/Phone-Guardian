import SwiftUI
import os.log

struct PrivacyControlView: View {
    @StateObject private var vpnManager = VPNManager()
    @StateObject private var trafficAnalyzer: TrafficAnalyzer
    @State private var showingDetectionLog = false
    @State private var showingSettings = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init() {
        let vpn = VPNManager()
        self._vpnManager = StateObject(wrappedValue: vpn)
        self._trafficAnalyzer = StateObject(wrappedValue: TrafficAnalyzer(vpnManager: vpn))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Status Card
                statusCard
                
                // Control Buttons
                controlButtons
                
                // Statistics
                statisticsSection
                
                // Recent Detections
                recentDetectionsSection
                
                // Settings & Info
                settingsSection
            }
            .padding()
        }
        .navigationTitle("Privacy Control")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingDetectionLog) {
            DetectionLogView(vpnManager: vpnManager)
        }
        .sheet(isPresented: $showingSettings) {
            PrivacySettingsView(vpnManager: vpnManager, trafficAnalyzer: trafficAnalyzer)
        }
        .alert("INFILOC Alert", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("INFILOC")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Passive Location Access Detection")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Monitors network traffic to detect when apps or services attempt to access your location without your knowledge.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Status Card
    private var statusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: vpnManager.isMonitoring ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(vpnManager.isMonitoring ? .green : .red)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(vpnManager.isMonitoring ? "Monitoring Active" : "Monitoring Inactive")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(trafficAnalyzer.currentStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if vpnManager.isMonitoring {
                HStack {
                    Image(systemName: "network")
                        .foregroundColor(.blue)
                    
                    Text("VPN Tunnel Active")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: startMonitoring) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Monitoring")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(vpnManager.isMonitoring)
            
            Button(action: stopMonitoring) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop Monitoring")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!vpnManager.isMonitoring)
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        let stats = trafficAnalyzer.getDetectionStats()
        
        return VStack(spacing: 16) {
            Text("Detection Statistics")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatCard(title: "Total", value: "\(stats.total)", icon: "chart.bar.fill", color: .blue)
                StatCard(title: "Today", value: "\(stats.today)", icon: "calendar", color: .green)
                StatCard(title: "This Week", value: "\(stats.thisWeek)", icon: "calendar.badge.clock", color: .orange)
            }
        }
    }
    
    // MARK: - Recent Detections Section
    private var recentDetectionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Detections")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showingDetectionLog = true
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            let recentDetections = Array(vpnManager.loadDetections().prefix(3))
            
            if recentDetections.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.shield")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("No location access detected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            } else {
                ForEach(recentDetections) { detection in
                    DetectionRow(detection: detection)
                }
            }
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingSettings = true }) {
                HStack {
                    Image(systemName: "gear")
                    Text("Privacy Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            .foregroundColor(.primary)
            
            Button(action: { showingDetectionLog = true }) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Detection History")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            .foregroundColor(.primary)
        }
    }
    
    // MARK: - Actions
    private func startMonitoring() {
        Task {
            await vpnManager.startVPN()
            trafficAnalyzer.startAnalysis()
            trafficAnalyzer.startRealTimeMonitoring()
        }
    }
    
    private func stopMonitoring() {
        Task {
            await vpnManager.stopVPN()
            trafficAnalyzer.stopAnalysis()
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