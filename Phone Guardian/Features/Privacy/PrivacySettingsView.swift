import SwiftUI

struct PrivacySettingsView: View {
    @ObservedObject var vpnManager: VPNManager
    @ObservedObject var trafficAnalyzer: TrafficAnalyzer
    @Environment(\.dismiss) private var dismiss
    
    @State private var autoStartMonitoring = false
    @State private var showNotifications = true
    @State private var silentMode = false
    @State private var maxLogEntries = 100
    @State private var showingDomainList = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // General Settings
                Section("General") {
                    Toggle("Auto-start on app launch", isOn: $autoStartMonitoring)
                        .onChange(of: autoStartMonitoring) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "infiloc_auto_start")
                        }
                    
                    Toggle("Show notifications", isOn: $showNotifications)
                        .onChange(of: showNotifications) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "infiloc_notifications")
                        }
                    
                    Toggle("Silent mode", isOn: $silentMode)
                        .onChange(of: silentMode) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "infiloc_silent_mode")
                        }
                }
                
                // Monitoring Settings
                Section("Monitoring") {
                    HStack {
                        Text("Max log entries")
                        Spacer()
                        Picker("Max log entries", selection: $maxLogEntries) {
                            Text("50").tag(50)
                            Text("100").tag(100)
                            Text("200").tag(200)
                            Text("500").tag(500)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .onChange(of: maxLogEntries) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "infiloc_max_logs")
                    }
                    
                    Button(action: { showingDomainList = true }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Monitored Domains")
                            Spacer()
                            Text("\(trafficAnalyzer.getKnownDomains().count)")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // VPN Status
                Section("VPN Status") {
                    HStack {
                        Image(systemName: vpnManager.isVPNEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(vpnManager.isVPNEnabled ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("VPN Tunnel")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(vpnManager.isVPNEnabled ? "Connected" : "Disconnected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    if vpnManager.isVPNEnabled {
                        HStack {
                            Image(systemName: "network")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Monitoring Status")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(trafficAnalyzer.currentStatus)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Statistics
                Section("Statistics") {
                    let stats = trafficAnalyzer.getDetectionStats()
                    
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total Detections")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("\(stats.total) events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Today")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("\(stats.today) events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("This Week")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("\(stats.thisWeek) events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                // Actions
                Section("Actions") {
                    Button(action: resetSettings) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                            Text("Reset to Defaults")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("About INFILOC")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Legal Notice
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Legal Notice")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("INFILOC is designed for personal privacy monitoring only. This tool does not decrypt, inject, or violate user privacy. All monitoring is performed locally on your device.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
            .sheet(isPresented: $showingDomainList) {
                DomainListView(trafficAnalyzer: trafficAnalyzer)
            }
            .sheet(isPresented: $showingAbout) {
                AboutINFILOCView()
            }
        }
    }
    
    // MARK: - Settings Management
    private func loadSettings() {
        autoStartMonitoring = UserDefaults.standard.bool(forKey: "infiloc_auto_start")
        showNotifications = UserDefaults.standard.bool(forKey: "infiloc_notifications")
        silentMode = UserDefaults.standard.bool(forKey: "infiloc_silent_mode")
        maxLogEntries = UserDefaults.standard.integer(forKey: "infiloc_max_logs")
        
        if maxLogEntries == 0 {
            maxLogEntries = 100 // Default value
        }
    }
    
    private func resetSettings() {
        autoStartMonitoring = false
        showNotifications = true
        silentMode = false
        maxLogEntries = 100
        
        UserDefaults.standard.removeObject(forKey: "infiloc_auto_start")
        UserDefaults.standard.removeObject(forKey: "infiloc_notifications")
        UserDefaults.standard.removeObject(forKey: "infiloc_silent_mode")
        UserDefaults.standard.removeObject(forKey: "infiloc_max_logs")
    }
}

// MARK: - Domain List View
struct DomainListView: View {
    @ObservedObject var trafficAnalyzer: TrafficAnalyzer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(trafficAnalyzer.getKnownDomains().keys.sorted()), id: \.self) { domain in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(domain)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(trafficAnalyzer.getKnownDomains()[domain] ?? "Unknown Service")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Monitored Domains")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - About INFILOC View
struct AboutINFILOCView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 64))
                            .foregroundColor(.accentColor)
                        
                        Text("INFILOC")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Passive Location Access Detection System")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What is INFILOC?")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("INFILOC is a privacy-focused monitoring system that passively detects when apps or services attempt to access your location without your explicit knowledge. It uses a VPN-based approach to monitor network traffic and identify location-related requests.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it Works")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            PrivacyFeatureRow(icon: "network", title: "VPN Tunnel", description: "Creates a local VPN tunnel to monitor outgoing traffic")
                            PrivacyFeatureRow(icon: "magnifyingglass", title: "Domain Analysis", description: "Analyzes network requests to known location service domains")
                            PrivacyFeatureRow(icon: "bell", title: "Real-time Detection", description: "Alerts you when location access is detected")
                            PrivacyFeatureRow(icon: "lock", title: "Privacy First", description: "All processing happens locally on your device")
                        }
                    }
                    
                    // Supported Services
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Supported Services")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ServiceTag("Find My iPhone")
                            ServiceTag("Life360")
                            ServiceTag("Snapchat")
                            ServiceTag("WhatsApp")
                            ServiceTag("Google Maps")
                            ServiceTag("Facebook")
                            ServiceTag("Uber")
                            ServiceTag("And more...")
                        }
                    }
                    
                    // Privacy Notice
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacy & Security")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("• No data is sent to external servers\n• All monitoring is performed locally\n• No personal information is collected\n• VPN tunnel is device-local only\n• Compatible with iOS privacy guidelines")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Version Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Version Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Version:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Build:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("10")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("About INFILOC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ServiceTag: View {
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.ultraThinMaterial)
            )
            .foregroundColor(.primary)
    }
} 